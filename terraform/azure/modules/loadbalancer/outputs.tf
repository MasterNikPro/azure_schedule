output "debug_lb" {
  value = var.load_balancer.name
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = var.load_balancer.type == "public" ? azurerm_public_ip.lb_public_ip[0].ip_address : null
}

output "backend_pool_id" {
  description = "ID of the load balancer backend address pool"
  value       = azurerm_lb_backend_address_pool.example.id
}
