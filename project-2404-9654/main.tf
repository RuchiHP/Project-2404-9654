locals {
  humber_id = "2404-9654"
  location  = "centralus"

  common_tags = {
    Project        = "CCGC 5502 Terraform Project"
    Name           = "ruchi.patel, sukrutha.srirangam"
    ExpirationDate = "2027-12-31"
    Environment    = "Learning"
  }

  # Linux VMs: name => availability zone (add/remove entries to scale)
  linux_vms = {
    "${local.humber_id}-c-vm1" = "1"
    "${local.humber_id}-c-vm2" = "2"
    "${local.humber_id}-c-vm3" = "3"
  }

  windows_name_prefix = "${local.humber_id}-w-vm"
  windows_count       = 1
}

module "rgroup" {
  source   = "./modules/rgroup-2404-9654"
  rg_name  = "${local.humber_id}-RG"
  location = local.location
  tags     = local.common_tags
}

module "network" {
  source                  = "./modules/network-2404-9654"
  rg_name                 = module.rgroup.rg_name
  location                = local.location
  vnet_name               = "${local.humber_id}-VNET"
  vnet_address_space      = ["10.0.0.0/16"]
  subnet_name             = "${local.humber_id}-SUBNET"
  subnet_address_prefixes = ["10.0.1.0/24"]
  nsg_name                = "${local.humber_id}-NSG"
  nsg_inbound_rules = {
    "allow-ssh-22"     = { priority = 100, port = "22" }
    "allow-rdp-3389"   = { priority = 110, port = "3389" }
    "allow-winrm-5985" = { priority = 120, port = "5985" }
    "allow-http-80"    = { priority = 130, port = "80" }
  }
  tags = local.common_tags
}

module "common" {
  source               = "./modules/common-2404-9654"
  rg_name              = module.rgroup.rg_name
  location             = local.location
  law_name             = "${local.humber_id}-LAW"
  law_sku              = "PerGB2018"
  law_retention_days   = 30
  rsv_name             = "RSV-${local.humber_id}" # must start with a letter
  rsv_sku              = "Standard"
  storage_account_name = "24049654projectsa" # no hyphens allowed
  storage_tier         = "Standard"
  storage_replication  = "LRS"
  tags                 = local.common_tags
}

module "vmlinux" {
  source           = "./modules/vmlinux-2404-9654"
  rg_name          = module.rgroup.rg_name
  location         = local.location
  linux_vms        = local.linux_vms
  vm_size          = "Standard_B2ats_v2"
  admin_username   = "ruchiadmin"
  public_key_path  = "~/.ssh/id_rsa_tf.pub"
  private_key_path = "~/.ssh/id_rsa_tf"
  subnet_id        = module.network.subnet_id
  boot_diag_uri    = module.common.storage_account_blob_endpoint
  dns_label_prefix = "rp"
  os_disk_type     = "Standard_LRS"
  os_disk_size_gb  = 32
  image = {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_2-gen2"
    version   = "latest"
  }
  nw_extension = {
    name      = "NetworkWatcherAgentLinux"
    publisher = "Microsoft.Azure.NetworkWatcher"
    type      = "NetworkWatcherAgentLinux"
    version   = "1.0"
  }
  ama_extension = {
    name      = "AzureMonitorLinuxAgent"
    publisher = "Microsoft.Azure.Monitor"
    type      = "AzureMonitorLinuxAgent"
    version   = "1.0"
  }
  tags = local.common_tags
}

module "vmwindows" {
  source           = "./modules/vmwindows-2404-9654"
  rg_name          = module.rgroup.rg_name
  location         = local.location
  vm_count         = local.windows_count
  vm_name_prefix   = local.windows_name_prefix
  avset_name       = "${local.humber_id}-w-avset"
  vm_size          = "Standard_B2als_v2"
  admin_username   = "ruchiadmin"
  admin_password   = "Rproject@2404"
  subnet_id        = module.network.subnet_id
  boot_diag_uri    = module.common.storage_account_blob_endpoint
  dns_label_prefix = "rp"
  os_disk_type     = "StandardSSD_LRS"
  os_disk_size_gb  = 127
  image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  tags = local.common_tags
}

module "datadisk" {
  source       = "./modules/datadisk-2404-9654"
  rg_name      = module.rgroup.rg_name
  location     = local.location
  disk_size_gb = 10
  disk_type    = "Standard_LRS"
  lun          = 0
  caching      = "ReadWrite"
  data_disks = merge(
    { for name, zone in local.linux_vms :
    name => { vm_id = module.vmlinux.vm_ids[name], zone = zone } },
    { for i in range(local.windows_count) :
    "${local.windows_name_prefix}${i + 1}" => { vm_id = module.vmwindows.vm_ids[i], zone = null } }
  )
  tags = local.common_tags

  # Attach disks only after VMs + extensions finish (avoids "operation in progress" conflicts)
  depends_on = [module.vmlinux, module.vmwindows]
}

module "loadbalancer" {
  source        = "./modules/loadbalancer-2404-9654"
  rg_name       = module.rgroup.rg_name
  location      = local.location
  lb_name       = "${local.humber_id}-LB"
  lb_pip_name   = "${local.humber_id}-LB-pip"
  lb_pip_zones  = ["1", "2", "3"]
  frontend_name = "${local.humber_id}-LB-frontend"
  pool_name     = "${local.humber_id}-LB-backendpool"
  probe_name    = "${local.humber_id}-LB-probe-http"
  probe_port    = 80
  rule_name     = "${local.humber_id}-LB-rule-http"
  frontend_port = 80
  backend_port  = 80
  backend_nics = { for name, zone in local.linux_vms :
    name => {
      nic_id        = module.vmlinux.nic_ids[name]
      ipconfig_name = module.vmlinux.ipconfig_names[name]
    }
  }
  tags = local.common_tags
}

module "database" {
  source                = "./modules/database-2404-9654"
  rg_name               = module.rgroup.rg_name
  location              = local.location
  db_name               = "${local.humber_id}-psql-group"
  db_version            = "16"
  admin_login           = "psqladmin"
  admin_password        = "Rdata@2404"
  sku_name              = "B_Standard_B1ms"
  storage_mb            = 32768
  backup_retention_days = 7
  zone                  = "1"
  tags                  = local.common_tags
}
