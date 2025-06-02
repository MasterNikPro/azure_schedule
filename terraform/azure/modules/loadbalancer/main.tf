resource "azurerm_public_ip" "lb_public_ip" {
  count               = var.load_balancer.type == "public" ? 1 : 0
  name                = "${var.load_balancer.name}-ip"
  location            = var.project_values["location"]
  resource_group_name = var.project_values["resource_group_name"]
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "example" {
  name                = var.load_balancer.name
  location            = var.project_values["location"]
  resource_group_name = var.project_values["resource_group_name"]
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = var.load_balancer.type == "public" ? azurerm_public_ip.lb_public_ip[0].id : null
    # subnet_id         = var.load_balancer.type == "internal" ? azurerm_subnet.internal_subnet.id : null
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.example.id
}

resource "azurerm_lb_probe" "example" {
  name            = "health-probe"
  loadbalancer_id = azurerm_lb.example.id
  port            = var.load_balancer.probe_port
}

resource "azurerm_lb_rule" "example" {
  name                           = "lb-rule"
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = title(var.load_balancer.protocol)
  frontend_port                  = var.load_balancer.frontend_port
  backend_port                   = var.load_balancer.backend_port
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.example.id
}
