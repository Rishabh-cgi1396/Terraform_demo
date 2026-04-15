output "public_ip" {
  value = try(azurerm_public_ip.pip[0].ip_address, null)
}
