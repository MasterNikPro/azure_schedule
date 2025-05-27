# Azure Provider Configuration
variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

# Resource Configuration
# Note: resource_group_name and location are now read from config.json
# These variables are kept for backward compatibility
variable "resource_group_name" {
  description = "Name of the resource group (overridden by config.json)"
  type        = string
  default     = "TerraformResourceGroup"
}

variable "location" {
  description = "Azure region where resources will be created (overridden by config.json)"
  type        = string
  default     = "Central US"
}

variable "db_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_admin_password) >= 8
    error_message = "Database administrator password must be at least 8 characters long."
  }
}

variable "db_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "postgres"
}

variable "allowed_ips" {
  description = "List of allowed IP addresses/CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Customize with your IP ranges
}

variable "use_key_vault_for_auth" {
  description = "Whether to use Key Vault for Azure provider authentication"
  type        = bool
  default     = false
}

variable "use_key_vault_for_db_credentials" {
  description = "Whether to use Key Vault for database credentials"
  type        = bool
  default     = true
}
