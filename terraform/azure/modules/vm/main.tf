locals {
  size_map = {
    small  = "Standard_D2s_v3"
    medium = "Standard_D4s_v3"
    large  = "Standard_E2s_v3"
  }

  os_image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_public_ip" "main" {
  for_each = { for vm in var.vm_instances : vm.name => vm if vm.public_ip }

  name                = "${each.value.name}-public-ip"
  location            = var.location_azurerm
  resource_group_name = var.resource_group_name_azurerm
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  for_each = { for vm in var.vm_instances : vm.name => vm }

  name                = "${each.value.name}-nic"
  location            = var.location_azurerm
  resource_group_name = var.resource_group_name_azurerm

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.azurerm_subnet
    private_ip_address_allocation = "Dynamic"
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

  size           = local.size_map.small
  admin_username = var.hostname

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id
  ]

  os_disk {
    caching              = local.os_disk.caching
    storage_account_type = local.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = local.os_image.publisher
    offer     = local.os_image.offer
    sku       = local.os_image.sku
    version   = local.os_image.version
  }

  admin_ssh_key {
    username   = var.hostname
    public_key = join("\n", var.ssh_keys)
  }

  tags = {
    name = "${each.value.name}-linux-vm"
  }
}
