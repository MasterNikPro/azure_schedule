#!/bin/bash
set -euo pipefail

CONFIG_PATH=$1
SERVICE_PRINCIPAL_NAME=$(grep -oP '"terraform_username":\s*"\K[^"]+' "$CONFIG_PATH")
SERVICE_PRINCIPAL_ROLE="Owner"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
ASSIGNEE_ID=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[0].id" -o tsv)
KEY_FILE="${2%.json}.json"

STORAGE_ACCOUNT_NAME="$(grep -oP '"storage_account_name_azurerm":\s*"\K[^"]+' "$CONFIG_PATH")$(date +%s)"
CONTAINER_NAME=$(grep -oP '"bucket_state_name":\s*"\K[^"]+' "$CONFIG_PATH")
RESOURCE_GROUP=$(grep -oP '"resource_group_name_azurerm":\s*"\K[^"]+' "$CONFIG_PATH")
LOCATION=$(grep -oP '"location_azurerm":\s*"\K[^"]+' "$CONFIG_PATH")

KEY_VAULT_NAME="$(grep -oP '"key_vault_name_azurerm":\s*"\K[^"]+' "$CONFIG_PATH")"
DB_USERNAME=$(grep -oP '"db-username":\s*"\K[^"]+' "$CONFIG_PATH")
DB_PASS=$(grep -oP '"db-pass":\s*"\K[^"]+' "$CONFIG_PATH")
SECRET_NAME_DB_USERNAME=$(grep -o 'db-username[:]*' "$CONFIG_PATH")
SECRET_NAME_DB_PASS=$(grep -o 'db-pass[:]*' "$CONFIG_PATH")
#########################################################################
if [[ -z "$SUBSCRIPTION_ID" ]]; then
	echo "=== Error: Unable to retrieve Azure subscription ID."
	exit 1
else
	echo "=== Project's ID: '$SUBSCRIPTION_ID' ==="
	echo
fi
#########################################################################
if az ad sp list --display-name $SERVICE_PRINCIPAL_NAME | grep -q '"displayName": $SERVICE_PRINCIPAL_NAME'; then
    echo "=== Service principal exists. ==="
	echo
else
    echo "=== Service principal does not exist. Creating... ==="
	az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" \
		--role $SERVICE_PRINCIPAL_ROLE \
		--scopes "/subscriptions/$SUBSCRIPTION_ID" > "$KEY_FILE"
	echo
fi
#########################################################################
echo "=== Creating a resource group: $RESOURCE_GROUP ==="
if az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
	echo "=== Resource group '$RESOURCE_GROUP' exists. ==="
	echo
else
	echo "=== Resource group '$RESOURCE_GROUP' does not exist. Creating... ==="
	az group create --name $RESOURCE_GROUP --location $LOCATION
	echo
fi
#########################################################################
echo "=== Creating Azure Key Vault ==="
if az keyvault create --name "$KEY_VAULT_NAME" \
		--resource-group "$RESOURCE_GROUP" \
		--location "$LOCATION"; then
	echo
else
	echo
fi
#########################################################################
echo "=== Assigmenting roles ==="
KEY_VAULT_ROLES=(
	"Key Vault Administrator"
)
SCOPE=$(az keyvault show --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP" --query "id" -o tsv)
for role in "${KEY_VAULT_ROLES[@]}"; do
	echo "=== Assigmenting role: '$role'... ==="
	az role assignment create \
		--assignee "$ASSIGNEE_ID" \
		--role "$role" \
		--scope "$SCOPE" || echo "=== Failed to assignment: $role ==="
done
echo
#########################################################################
azureLoggin() {
	echo "=== Logging... ===" 
	AZURE_CLIENT_ID=$(grep -oP '"appId":\s*"\K[^"]+' $KEY_FILE)
	AZURE_CLIENT_SECRET=$(grep -oP '"password":\s*"\K[^"]+' $KEY_FILE)
	AZURE_TENANT_ID=$(grep -oP '"tenant":\s*"\K[^"]+' $KEY_FILE)

	az login --service-principal \
		--username "$AZURE_CLIENT_ID" \
		--password "$AZURE_CLIENT_SECRET" \
		--tenant "$AZURE_TENANT_ID"
	echo
}
azureLoggin
#########################################################################
check_secret_exists() {
    az keyvault secret show --vault-name "$1" --name "$2"
}
# Function to create a secret if it doesn't already exist
createSecret() {
	KEY_VAULT_NAME=$1
	SECRET_NAME=$2
	SECRET_VALUE=$3

	if check_secret_exists "$KEY_VAULT_NAME" "$SECRET_NAME"; then
		echo "=== Secret '$SECRET_NAME' already exists in Key Vault '$KEY_VAULT_NAME'. ==="
		echo
	else
		echo "=== Creating secret '$SECRET_NAME'... ==="
		if az keyvault secret set --vault-name "$KEY_VAULT_NAME" \
				--name "$SECRET_NAME" \
				--value "$SECRET_VALUE"; then
			echo "=== Secret '$SECRET_NAME' created and value added. ==="
			echo
		else
			echo " Failed to create secret '$SECRET_NAME'."
			exit 1
		fi
	fi
}
createSecret "$KEY_VAULT_NAME" "$SECRET_NAME_DB_USERNAME" "$DB_USERNAME"
createSecret "$KEY_VAULT_NAME" "$SECRET_NAME_DB_PASS" "$DB_PASS"
#########################################################################
echo "=== Setting Up Azure Storage Account(-s) ==="
STORAGE_ACCOUNT_NAMES=(
	"$STORAGE_ACCOUNT_NAME"
)
for account in "${STORAGE_ACCOUNT_NAMES[@]}"; do
	if az storage account show --name "$account" \
			--resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
		echo "=== Azure Storage account '$account' already exists. ==="
		echo
	else
		az storage account create --name "$account" \
			--resource-group "$RESOURCE_GROUP" \
			--location "$LOCATION" \
			--sku "Standard_LRS"
		echo
	fi
done
echo
#########################################################################
if az storage container show \
		--name "$CONTAINER_NAME" \
		--account-name "$STORAGE_ACCOUNT_NAME" \
		--resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
	echo "=== Storage container '$CONTAINER_NAME' exists in account '$STORAGE_ACCOUNT_NAME'. ==="
	echo
else
	echo "=== Creating the container $CONTAINER_NAME ==="
	az storage container create --name "$CONTAINER_NAME" \
		--account-name "$STORAGE_ACCOUNT_NAME"
	echo
fi
#########################################################################
ACCOUNT_KEY=$(az storage account keys list \
	--resource-group "$RESOURCE_GROUP" \
	--account-name "$STORAGE_ACCOUNT_NAME" \
	--query "[0].value" -o tsv)
#########################################################################
startTerraform() {
	echo "🚀 STARTING TERRAFORM"
	terraform init --reconfigure \
		-backend-config="storage_account_name=$1" \
		-backend-config="container_name=$2" \
		-backend-config="key=terraform.tfstate" \
		-backend-config="access_key=$3"

	terraform plan && terraform apply --auto-approve
}
startTerraform "$STORAGE_ACCOUNT_NAME" "$CONTAINER_NAME" "$ACCOUNT_KEY"
#########################################################################
