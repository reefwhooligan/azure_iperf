output "cloud_public_ip" {
  value       = azurerm_linux_virtual_machine.main.public_ip_address
  description = "Remote public IP for VPN"
}

output "cloud_private_ip" {
  value       = azurerm_network_interface.main.private_ip_address
  description = "Remote IP for running iperf"
}

output "cloud_subnet" {
  value       = azurerm_subnet.main.address_prefixes[0]
  description = "Remote subnet for VPN"
}

output "client_ip" {
  value       = var.client_ip
  description = "Local public IP for VPN"
}

output "client_subnet" {
  value       = var.client_subnet
  description = "Local subnet for VPN"
}

output "psk" {
  value       = nonsensitive(random_password.psk.result)
  description = "Pre-shared key for VPN"
}