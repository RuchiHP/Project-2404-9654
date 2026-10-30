output "hostnames" { value = azurerm_windows_virtual_machine.vm[*].computer_name }
output "fqdns" { value = azurerm_public_ip.pip[*].fqdn }
output "private_ips" { value = azurerm_network_interface.nic[*].private_ip_address }
output "public_ips" { value = azurerm_public_ip.pip[*].ip_address }
output "vm_ids" { value = azurerm_windows_virtual_machine.vm[*].id }
