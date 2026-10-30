variable "rg_name" { type = string }
variable "location" { type = string }
variable "data_disks" {
  description = "Map of VM name => { vm_id, zone }"
  type = map(object({
    vm_id = string
    zone  = string
  }))
}
variable "disk_size_gb" { type = number }
variable "disk_type" { type = string }
variable "lun" { type = number }
variable "caching" { type = string }
variable "tags" { type = map(string) }
