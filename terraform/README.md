# Azure PostgreSQL Terraform Infrastructure

This repository contains Terraform configurations for deploying Azure PostgreSQL Flexible Server infrastructure using modular best practices.

## Project Structure

```
terraform/
├── azure/                    # Main configuration
│   ├── main.tf              # Provider and module configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── versions.tf          # Provider version requirements
│   └── terraform.tfvars.example  # Example variable values
└── modules/
    └── postgresql/          # PostgreSQL module
        ├── main.tf          # PostgreSQL resource definition
        ├── variables.tf     # Module input variables
        ├── outputs.tf       # Module outputs
        ├── versions.tf      # Module version requirements
        └── README.md        # Module documentation
```

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd terraform/azure
   ```

2. **Copy and configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your Azure credentials and preferences
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables

You must provide the following variables in your `terraform.tfvars` file:

- `client_id` - Azure Service Principal Client ID
- `client_secret` - Azure Service Principal Client Secret  
- `subscription_id` - Azure Subscription ID
- `tenant_id` - Azure Tenant ID
- `db_admin_password` - PostgreSQL administrator password (minimum 8 characters)

### Optional Variables

- `resource_group_name` - Name of the resource group (default: "TerraformResourceGroup")
- `location` - Azure region (default: "Central US")
- `db_server_name` - PostgreSQL server name (default: "myserverdbtest")

## Modules

### PostgreSQL Module

The PostgreSQL module (`modules/postgresql`) creates an Azure PostgreSQL Flexible Server with the following features:

- Configurable PostgreSQL version (11-16)
- Flexible storage and backup options
- Availability zone configuration
- Input validation for critical parameters
- Comprehensive outputs for integration

See [modules/postgresql/README.md](modules/postgresql/README.md) for detailed documentation.

## Outputs

After successful deployment, the following outputs will be available:

- `database_server_name` - The name of the PostgreSQL server
- `database_fqdn` - The fully qualified domain name
- `database_location` - The Azure region
- `database_admin_login` - The administrator login name
- `database_server_id` - The Azure resource ID
- `database_version` - The PostgreSQL version

## Best Practices Implemented

- **Modular Design**: Database configuration is separated into a reusable module
- **Input Validation**: Critical parameters have validation rules
- **Sensitive Variables**: Credentials are marked as sensitive
- **Documentation**: Comprehensive README files and variable descriptions
- **Version Constraints**: Terraform and provider versions are pinned
- **Output Descriptions**: All outputs include helpful descriptions
- **Example Configuration**: terraform.tfvars.example provided

## Security Considerations

- Store sensitive variables (credentials) securely
- Consider using Azure Key Vault for password management
- Review network access settings for production use
- Enable geo-redundant backups for production workloads

## Contributing

When making changes:

1. Update module documentation if adding new features
2. Add validation rules for new variables where appropriate
3. Update example configurations
4. Test changes in a development environment first 