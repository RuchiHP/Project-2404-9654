resource "azurerm_managed_disk" "disk" {
  for_each             = var.data_disks
  name                 = "${each.key}-datadisk1"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = var.disk_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
  zone                 = each.value.zone # must match the VM's zone (null for the Windows VM)
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  for_each           = var.data_disks
  managed_disk_id    = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id = each.value.vm_id
  lun                = var.lun
  caching            = var.caching
}
