resource "azurerm_public_ip" "pip" {
  for_each            = var.linux_vms
  name                = "${each.key}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value]
  domain_name_label   = "${var.dns_label_prefix}${each.key}"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  for_each            = var.linux_vms
  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "${each.key}-ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.linux_vms
  name                            = each.key
  computer_name                   = each.key
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm_size
  zone                            = each.value
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.public_key_path))
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diag_uri
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "network_watcher" {
  for_each                   = var.linux_vms
  name                       = var.nw_extension.name
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[each.key].id
  publisher                  = var.nw_extension.publisher
  type                       = var.nw_extension.type
  type_handler_version       = var.nw_extension.version
  auto_upgrade_minor_version = true
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "azure_monitor" {
  for_each                   = var.linux_vms
  name                       = var.ama_extension.name
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[each.key].id
  publisher                  = var.ama_extension.publisher
  type                       = var.ama_extension.type
  type_handler_version       = var.ama_extension.version
  auto_upgrade_minor_version = true
  tags                       = var.tags

  # One extension at a time per VM (Azure rejects parallel extension operations)
  depends_on = [azurerm_virtual_machine_extension.network_watcher]
}
