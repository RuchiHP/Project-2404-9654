variable "rg_name" { type = string }
variable "location" { type = string }
variable "linux_vms" {
  description = "Map of VM name => availability zone"
  type        = map(string)
}
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "public_key_path" { type = string }
variable "private_key_path" { type = string }
variable "subnet_id" { type = string }
variable "boot_diag_uri" { type = string }
variable "dns_label_prefix" { type = string }
variable "os_disk_type" { type = string }
variable "os_disk_size_gb" { type = number }
variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
variable "nw_extension" {
  type = object({
    name      = string
    publisher = string
    type      = string
    version   = string
  })
}
variable "ama_extension" {
  type = object({
    name      = string
    publisher = string
    type      = string
    version   = string
  })
}
variable "tags" { type = map(string) }
