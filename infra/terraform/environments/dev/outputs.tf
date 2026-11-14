output "resource_group_name" {
  description = "DEV Resource Group name"
  value       = data.azurerm_resource_group.dev.name
}

output "resource_group_location" {
  description = "DEV Resource Group location"
  value       = data.azurerm_resource_group.dev.location
}

output "vnet_id" {
  description = "DEV Virtual Network ID"
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "DEV Virtual Network name"
  value       = module.network.vnet_name
}

output "subnet_ids" {
  description = "DEV subnet IDs"
  value       = module.network.subnet_ids
}

output "nsg_ids" {
  description = "DEV Network Security Group IDs"
  value       = module.network.nsg_ids
}
output "log_analytics_id" {
  description = "ID of the development Log Analytics Workspace."
  value       = module.log_analytics.id
}

output "log_analytics_name" {
  description = "Name of the development Log Analytics Workspace."
  value       = module.log_analytics.name
}

output "log_analytics_workspace_id" {
  description = "Workspace ID of the development Log Analytics Workspace."
  value       = module.log_analytics.workspace_id
}

output "acr_id" {
  description = "ID of the development Azure Container Registry."
  value       = module.acr.id
}

output "acr_name" {
  description = "Name of the development Azure Container Registry."
  value       = module.acr.name
}

output "acr_login_server" {
  description = "Login server of the development Azure Container Registry."
  value       = module.acr.login_server
}


output "key_vault_id" {
  description = "ID of the development Key Vault."
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "Name of the development Key Vault."
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the development Key Vault."
  value       = module.key_vault.vault_uri
}


output "managed_identity_id" {
  description = "Resource ID of the User Assigned Managed Identity."
  value       = module.managed_identity.id
}

output "managed_identity_client_id" {
  description = "Client ID of the User Assigned Managed Identity."
  value       = module.managed_identity.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the User Assigned Managed Identity."
  value       = module.managed_identity.principal_id
}



output "aks_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.id
}

output "aks_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.name
}

output "aks_kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet identity."
  value       = module.aks.kubelet_identity_object_id
}

output "aks_principal_id" {
  description = "Principal ID of the AKS cluster managed identity."
  value       = module.aks.principal_id
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster."
  value       = module.aks.oidc_issuer_url
}

output "aks_acr_pull_role_assignment_id" {
  description = "ID of the AKS AcrPull role assignment."
  value       = module.rbac.aks_acr_pull_role_assignment_id
}

output "keyvault_secrets_role_assignment_id" {
  description = "ID of the Key Vault Secrets User role assignment."
  value       = module.rbac.keyvault_secrets_role_assignment_id
}

output "sql_server_id" {
  value = module.sql.server_id
}

output "sql_server_name" {
  value = module.sql.server_name
}

output "sql_server_fqdn" {
  value = module.sql.server_fqdn
}

output "sql_database_id" {
  value = module.sql.database_id
}

output "sql_database_name" {
  value = module.sql.database_name
}

output "sql_private_dns_zone_id" {
  value = module.sql_private_dns.id
}

output "sql_private_dns_zone_name" {
  value = module.sql_private_dns.name
}

output "sql_private_endpoint_id" {
  value = module.sql_private_endpoint.id
}

output "sql_private_endpoint_name" {
  value = module.sql_private_endpoint.name
}

output "sql_private_endpoint_ip" {
  value = module.sql_private_endpoint.private_ip_addresses
}

output "storage_account_id" {
  value = module.storage.id
}

output "storage_account_name" {
  value = module.storage.name
}

output "storage_blob_endpoint" {
  value = module.storage.primary_blob_endpoint
}

output "storage_private_dns_zone_id" {
  value = module.storage_private_dns.id
}

output "storage_private_dns_zone_name" {
  value = module.storage_private_dns.name
}

output "storage_private_endpoint_id" {
  value = module.storage_private_endpoint.id
}

output "storage_private_endpoint_name" {
  value = module.storage_private_endpoint.name
}

output "storage_private_endpoint_ip" {
  value = module.storage_private_endpoint.private_ip_addresses
}

output "appgw_public_ip_id" {
  description = "Application Gateway Public IP resource ID"
  value       = module.appgw_public_ip.id
}

output "appgw_public_ip_address" {
  description = "Application Gateway public IP address"
  value       = module.appgw_public_ip.ip_address
}

output "waf_policy_id" {
  description = "WAF Policy resource ID"
  value       = module.waf.id
}

output "waf_policy_name" {
  description = "WAF Policy name"
  value       = module.waf.name
}

output "application_gateway_id" {
  description = "Application Gateway resource ID"
  value       = module.application_gateway.id
}

output "application_gateway_name" {
  description = "Application Gateway name"
  value       = module.application_gateway.name
}

output "action_group_id" {
  description = "Azure Monitor Action Group ID"
  value       = module.action_group.id
}

output "action_group_name" {
  description = "Azure Monitor Action Group name"
  value       = module.action_group.name
}

output "appgw_unhealthy_alert_id" {
  value = module.appgw_unhealthy_alert.id
}

output "sql_cpu_alert_id" {
  value = module.sql_cpu_alert.id
}

output "storage_availability_alert_id" {
  value = module.storage_availability_alert.id
}