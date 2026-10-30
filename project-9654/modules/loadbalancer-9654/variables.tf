variable "rg_name" { type = string }
variable "location" { type = string }
variable "lb_name" { type = string }
variable "lb_pip_name" { type = string }
variable "lb_pip_zones" { type = list(string) }
variable "frontend_name" { type = string }
variable "pool_name" { type = string }
variable "probe_name" { type = string }
variable "probe_port" { type = number }
variable "rule_name" { type = string }
variable "frontend_port" { type = number }
variable "backend_port" { type = number }
variable "backend_nics" {
  type = map(object({
    nic_id        = string
    ipconfig_name = string
  }))
}
variable "tags" { type = map(string) }
