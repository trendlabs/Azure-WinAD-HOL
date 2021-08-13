output "public_ip_address" {
  value = azurerm_public_ip.static.*.ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.primary.*.private_ip_address
}
