output "vm_name" {
  description = "Name of the vm"
  value = {
    for vm_name, vm_data in azurerm_linux_virtual_machine.main :
    vm_name => {
      name                   = vm_data.name
      size                   = vm_data.size
      os_disk                = vm_data.os_disk
      source_image_reference = vm_data.source_image_reference
    }
  }
}

output "vm_ids" {
  value = { for vm_key, vm in azurerm_linux_virtual_machine.main : vm_key => vm.id }
}

output "kubernetes_workers" {
  description = "List of all VMs formatted for Kubernetes deployment"
  value = [
    for vm_name, vm_data in azurerm_linux_virtual_machine.main : {
      name       = vm_data.name
      public_ip  = contains(keys(azurerm_public_ip.main), vm_name) ? azurerm_public_ip.main[vm_name].ip_address : ""
      private_ip = azurerm_network_interface.main[vm_name].ip_configuration[0].private_ip_address
      vm_size    = vm_data.size
    }
  ]
}