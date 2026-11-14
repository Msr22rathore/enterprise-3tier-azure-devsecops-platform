resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.kubelet_identity_object_id
}

resource "azurerm_role_assignment" "keyvault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.managed_identity_principal_id
}