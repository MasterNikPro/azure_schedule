# PostgreSQL Flexible Server Module

This Terraform module creates an Azure PostgreSQL Flexible Server with configurable options.

## Features

- Creates an Azure PostgreSQL Flexible Server
- Configurable PostgreSQL version (11-16)
- Flexible storage and backup options
- Availability zone configuration
- Input validation for critical parameters
- Comprehensive outputs for integration

## Usage

```hcl
module "postgresql" {
  source = "./modules/postgresql"

  server_name         = "my-postgres-server"
  resource_group_name = "my-resource-group"
  location           = "Central US"
  
  administrator_password = "YourSecurePassword123!"
  
  # Optional configurations
  postgresql_version = "16"
  sku_name          = "B_Standard_B2s"
  storage_mb        = 32768
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| server_name | The name of the PostgreSQL Flexible Server | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| administrator_password | The administrator password | `string` | n/a | yes |
| postgresql_version | The version of PostgreSQL | `string` | `"16"` | no |
| administrator_login | The administrator login name | `string` | `"postgres"` | no |
| sku_name | The SKU name | `string` | `"B_Standard_B2s"` | no |
| storage_mb | The max storage in MB | `number` | `32768` | no |
| backup_retention_days | The backup retention days | `number` | `7` | no |
| geo_redundant_backup_enabled | Whether geo-redundant backup is enabled | `bool` | `false` | no |
| auto_grow_enabled | Whether auto grow is enabled | `bool` | `false` | no |
| public_network_access_enabled | Whether public network access is enabled | `bool` | `true` | no |
| availability_zone | The availability zone | `string` | `"1"` | no |
| tags | A mapping of tags to assign | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| server_id | The ID of the PostgreSQL Flexible Server |
| server_name | The name of the PostgreSQL Flexible Server |
| server_fqdn | The FQDN of the PostgreSQL Flexible Server |
| server_location | The location of the PostgreSQL Flexible Server |
| administrator_login | The administrator login name |
| postgresql_version | The version of PostgreSQL |
| sku_name | The SKU name of the server |
| storage_mb | The storage size in MB |
| backup_retention_days | The backup retention days |
| public_network_access_enabled | Whether public network access is enabled |

## Validation

The module includes validation for:
- PostgreSQL version (must be 11-16)
- Administrator password (minimum 8 characters)
- Storage size (32 GB - 16 TB)
- Backup retention (7-35 days)
- Availability zone (1-3) 