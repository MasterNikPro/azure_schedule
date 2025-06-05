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
