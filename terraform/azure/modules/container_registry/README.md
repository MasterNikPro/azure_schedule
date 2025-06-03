# Azure Container Registry (ACR) Terraform Module

This module creates and manages Azure Container Registry instances for storing Docker images and other container artifacts.

## Features

- ✅ Creates Azure Container Registry with configurable SKU (Basic, Standard, Premium)

## Usage

### Basic Example

```hcl
module "container_registry" {
  source = "./modules/container_registry"

  registry_instances = {
    main = {
      name                          = "mycompanyacr"
      location                      = "North Europe"
      sku                          = "Standard"
      admin_enabled                = true
      public_network_access_enabled = true
      tags = {
        Environment = "production"
        Team        = "devops"
      }
    }
  }

  resource_group_name = "my-resource-group"
  
  project_tags = {
    Project   = "my-project"
    ManagedBy = "terraform"
  }
}
```

### Advanced Example with Private Endpoint

```hcl
module "container_registry" {
  source = "./modules/container_registry"

  registry_instances = {
    private_registry = {
      name                          = "myprivateacr"
      location                      = "North Europe"
      sku                          = "Premium"
      admin_enabled                = false
      public_network_access_enabled = false
  
      
      tags = {
        Environment = "production"
        Tier        = "critical"
      }
    }
  }

  resource_group_name = "my-resource-group"
  
  project_tags = {
    Project   = "my-project"
    ManagedBy = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| registry_instances | Map of container registry instances to create | `map(object)` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the container registry | `string` | n/a | yes |
| project_tags | Tags to be applied to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| registry_ids | IDs of the created container registries |
| registry_names | Names of the created container registries |
