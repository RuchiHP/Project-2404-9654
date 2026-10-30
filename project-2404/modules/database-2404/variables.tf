variable "rg_name" { type = string }
variable "location" { type = string }
variable "db_name" { type = string }
variable "db_version" { type = string }
variable "admin_login" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "sku_name" { type = string }
variable "storage_mb" { type = number }
variable "backup_retention_days" { type = number }
variable "zone" { type = string }
variable "tags" { type = map(string) }
