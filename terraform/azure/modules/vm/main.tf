resource "azurerm_public_ip" "main" {
  for_each = { for vm in var.vm_instances : vm.name => vm if vm.public_ip }

  name                = "${each.value.name}-public-ip"
  location            = var.location_azurerm
  resource_group_name = var.resource_group_name_azurerm
  allocation_method   = each.value.allocation_method
}

resource "azurerm_network_interface" "main" {
  for_each = { for vm in var.vm_instances : vm.name => vm }

  name                = "${each.value.name}-nic"
  location            = var.location_azurerm
  resource_group_name = var.resource_group_name_azurerm

  ip_configuration {
    name                          = each.value.ip_configuration_name
    subnet_id                     = var.azurerm_subnet
    private_ip_address_allocation = each.value.private_ip_address_allocation
    public_ip_address_id          = each.value.public_ip ? azurerm_public_ip.main[each.key].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  for_each = {
    for pair in flatten([
      for vm in var.vm_instances : [
        for sg in vm.security_groups : {
          key     = "${vm.name}-${sg}"
          vm_name = vm.name
          sg_name = sg
        }
      ] if length(vm.security_groups) > 0
    ]) : pair.key => pair
  }

  network_interface_id      = azurerm_network_interface.main[each.value.vm_name].id
  network_security_group_id = var.nsg_ids[each.value.sg_name]
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = { for vm in var.vm_instances : vm.name => vm }

  name                = each.value.name
  location            = var.location_azurerm
  resource_group_name = var.resource_group_name_azurerm

  size           = lookup(var.vm_instances_size_map[var.location_azurerm], each.value.size, "Standard_DC1ds_v3")
  admin_username = var.hostname

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id
  ]

  os_disk {
    caching              = lookup(var.os_disk[each.value.size], "caching", "ReadWrite")
    storage_account_type = lookup(var.os_disk[each.value.size], "storage_account_type", "Standard_LRS")
  }

  source_image_reference {
    publisher = lookup(var.os_image[var.location_azurerm], "publisher", "Canonical")
    offer     = lookup(var.os_image[var.location_azurerm], "offer", "0001-com-ubuntu-server-jammy")
    sku       = lookup(var.os_image[var.location_azurerm], "sku", "22_04-lts-gen2")
    version   = lookup(var.os_image[var.location_azurerm], "version", "latest")
  }

  admin_ssh_key {
    username   = var.hostname
    public_key = join("\n", var.ssh_keys)
  }

  # boot_diagnostics {
  #   storage_account_uri = var.storage_account_uri
  # }

  tags = {
    name = "${each.value.name}-linux-vm"
  }
}
