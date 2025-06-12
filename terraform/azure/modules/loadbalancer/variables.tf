variable "load_balancer" {
  type = object({
    name          = string
    type          = string
    frontend_port = number
    backend_port  = number
    backend_pool  = list(string)
    probe_port    = number
    protocol      = string
  })
}

variable "project_values" {
  type = map(string)
}

# New variable for VM network interfaces
variable "vm_network_interfaces" {
  description = "Map of VM network interface IDs for backend pool association"
  type        = map(string)
  default     = {}
}
