output "ports" {
	value = { for vm in var.vm_instances : vm.name => vm.port }
}
