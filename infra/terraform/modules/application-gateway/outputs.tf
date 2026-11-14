output "id" {
  description = "Application Gateway resource ID"
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "Application Gateway name"
  value       = azurerm_application_gateway.this.name
}