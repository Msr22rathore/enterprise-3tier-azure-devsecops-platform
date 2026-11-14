output "aks_acr_pull_role_assignment_id" {
  description = "ID of the AKS AcrPull role assignment."
  value       = azurerm_role_assignment.aks_acr_pull.id
}

output "keyvault_secrets_role_assignment_id" {
  description = "ID of the Key Vault Secrets User role assignment."
  value       = azurerm_role_assignment.keyvault_secrets_user.id
}