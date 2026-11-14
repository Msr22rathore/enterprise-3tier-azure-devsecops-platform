output "id" {
  description = "Public IP resource ID"
  value       = azurerm_public_ip.this.id
}

output "name" {
  description = "Public IP name"
  value       = azurerm_public_ip.this.name
}

output "ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "Public IP FQDN"
  value       = azurerm_public_ip.this.fqdn
}