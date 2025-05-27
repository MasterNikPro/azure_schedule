# Azure PostgreSQL Terraform Configuration

This Terraform configuration dynamically creates PostgreSQL instances based on the configuration defined in `config.json`. The `for_each` logic is now encapsulated within the PostgreSQL module for better organization and reusability.

## Architecture

The configuration uses a modular approach where:
- **Main configuration** (`main.tf`) calls the PostgreSQL module with database instances
- **PostgreSQL module** (`modules/postgresql/`) handles the `for_each` logic internally
- **Configuration** is read from `config.json` and processed in `locals.tf`

## Configuration Structure

### Database Configuration in config.json

The database instances are configured in the `config.json` file under the `databases` array:

```json
{
  "databases": [
    {
      "name": "maindb",
      "network": "main",
      "type": "postgres",
      "version": "14",
      "size": "small",
      "zone": ["a", "b"],
      "subnets": ["private-subnet", "private-subnet-2"],
      "port": 5432,
      "security_groups": ["db-sg"]
    }
  ]
}
```

### Size Mapping

The configuration automatically maps the `size` field to appropriate Azure SKUs and storage:

- **small**: `B_Standard_B1ms` with 32GB storage
- **medium**: `B_Standard_B2s` with 64GB storage  
- **large**: `GP_Standard_D2s_v3` with 128GB storage

### Project Configuration

Project-level settings are read from the `project` section in `config.json`:

```json
{
  "project": {
    "name": "my-infra",
    "environment": "dev",
    "location_azurerm": "West Europe",
    "resource_group_name_azurerm": "resource-group"
  }
}
```

## Usage

### Option 1: Key Vault Integration (Recommended)

1. **Configure your databases** in `config.json` under the `databases` array
2. **Run the enhanced bootstrap script**:
   ```bash
   chmod +x bootstrap-enhanced.sh
   ./bootstrap-enhanced.sh config.json service-principal
   ```
3. **Enable Key Vault in `terraform.tfvars`**:
   ```hcl
   use_key_vault_for_db_credentials = true
   use_key_vault_for_auth = false  # Set to true for full Key Vault auth
   ```
4. **Run Terraform**:
   ```bash
   terraform plan
   terraform apply
   ```

### Option 2: Traditional Variables

1. **Configure your databases** in `config.json` under the `databases` array
2. **Set credentials** in `terraform.tfvars`:
   ```hcl
   use_key_vault_for_db_credentials = false
   db_admin_username = "postgres"
   db_admin_password = "YourSecurePassword123!"
   ```
3. **Run Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs

The configuration provides several outputs:

- `postgresql_instances`: Detailed information about all created PostgreSQL instances
- `database_connection_strings`: Connection information for each database
- `config_summary`: Summary of the loaded configuration
- Legacy outputs for backward compatibility

## Module Structure

### PostgreSQL Module (`modules/postgresql/`)

The PostgreSQL module now handles multiple database instances internally:

- **Input**: Receives a map of database instances from the main configuration
- **Processing**: Uses `for_each` internally to create multiple PostgreSQL servers
- **Output**: Provides both individual instance details and aggregated information
- **Filtering**: Only processes databases with `type = "postgres"`

### Main Configuration

The main configuration is simplified and only needs to:
1. Read and process `config.json` in `locals.tf`
2. Pass the database instances map to the PostgreSQL module
3. Expose module outputs for external consumption

## Features

- **Modular Design**: `for_each` logic encapsulated within the PostgreSQL module
- **Dynamic Creation**: Automatically creates PostgreSQL instances based on config.json
- **Multiple Databases**: Supports creating multiple PostgreSQL instances
- **Flexible Configuration**: Easy to modify database settings in config.json
- **Environment-aware**: Uses project environment and naming conventions
- **Backward Compatible**: Maintains legacy outputs for existing integrations

## Retrieving Database Connection Information

### Using the Helper Script

After deployment, use the helper script to get connection information:

```bash
# Get connection info for all databases
./get-db-connection.sh your-key-vault-name

# Get connection info for a specific database
./get-db-connection.sh your-key-vault-name maindb
```

### Manual Key Vault Retrieval

```bash
# Get database credentials from Key Vault
az keyvault secret show --vault-name "your-key-vault" --name "db-username" --query "value" -o tsv
az keyvault secret show --vault-name "your-key-vault" --name "db-pass" --query "value" -o tsv

# Get database host from Terraform output
terraform output -json postgresql_instances
```

## Example Output

After running `terraform apply`, you'll see output similar to:

```
postgresql_instances = {
  "maindb" = {
    "database_name" = "maindb"
    "location" = "West Europe"
    "server_fqdn" = "my-infra-maindb-dev.postgres.database.azure.com"
    "server_name" = "my-infra-maindb-dev"
    "sku_name" = "B_Standard_B1ms"
    "storage_mb" = 32768
    "version" = "14"
  }
}

key_vault_info = {
  "key_vault_name" = "DB-secrets-new1234567890"
  "key_vault_uri" = "https://db-secrets-new1234567890.vault.azure.net/"
  "secrets_stored" = ["db-username", "db-pass"]
}
``` 