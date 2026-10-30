variable "rg_name" { type = string }
variable "location" { type = string }
variable "vm_count" { type = number }
variable "vm_name_prefix" { type = string }
variable "avset_name" { type = string }
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true
}
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
variable "tags" { type = map(string) }
