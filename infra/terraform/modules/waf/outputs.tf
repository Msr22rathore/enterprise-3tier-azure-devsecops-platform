output "id" {
  description = "WAF Policy resource ID"
  value       = azurerm_web_application_firewall_policy.this.id
}

output "name" {
  description = "WAF Policy name"
  value       = azurerm_web_application_firewall_policy.this.name
}