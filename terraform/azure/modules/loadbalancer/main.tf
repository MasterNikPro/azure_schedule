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

# Associate VMs with backend pool using network interface association
resource "azurerm_network_interface_backend_address_pool_association" "vm_pool_association" {
  for_each = var.vm_network_interfaces

  network_interface_id    = each.value
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
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

# HTTP probe and rule for K3s Ingress (Traefik)
resource "azurerm_lb_probe" "http_probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.example.id
  port            = 80
  protocol        = "Tcp"
}

resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}

# HTTPS probe and rule for K3s Ingress (Traefik)
resource "azurerm_lb_probe" "https_probe" {
  name            = "https-probe"
  loadbalancer_id = azurerm_lb.example.id
  port            = 443
  protocol        = "Tcp"
}

resource "azurerm_lb_rule" "https_rule" {
  name                           = "https-rule"
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.https_probe.id
}
