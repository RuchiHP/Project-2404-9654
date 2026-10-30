output "law_name" { value = azurerm_log_analytics_workspace.law.name }
output "law_id" { value = azurerm_log_analytics_workspace.law.id }
output "rsv_name" { value = azurerm_recovery_services_vault.rsv.name }
output "storage_account_name" { value = azurerm_storage_account.sa.name }
output "storage_account_blob_endpoint" { value = azurerm_storage_account.sa.primary_blob_endpoint }
