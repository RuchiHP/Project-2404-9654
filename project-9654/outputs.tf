output "resource_group_name" { value = module.rgroup.rg_name }

output "vnet_name" { value = module.network.vnet_name }
output "subnet_name" { value = module.network.subnet_name }

output "log_analytics_workspace_name" { value = module.common.law_name }
output "recovery_services_vault_name" { value = module.common.rsv_name }
output "storage_account_name" { value = module.common.storage_account_name }

output "linux_hostnames" { value = module.vmlinux.hostnames }
output "linux_fqdns" { value = module.vmlinux.fqdns }
output "linux_private_ips" { value = module.vmlinux.private_ips }
output "linux_public_ips" { value = module.vmlinux.public_ips }

output "windows_hostnames" { value = module.vmwindows.hostnames }
output "windows_fqdns" { value = module.vmwindows.fqdns }
output "windows_private_ips" { value = module.vmwindows.private_ips }
output "windows_public_ips" { value = module.vmwindows.public_ips }

output "load_balancer_name" { value = module.loadbalancer.lb_name }
output "database_name" { value = module.database.db_name }
