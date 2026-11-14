data "azurerm_resource_group" "dev" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}



module "network" {
  source = "../../modules/network"

  resource_group_name = data.azurerm_resource_group.dev.name
  location            = data.azurerm_resource_group.dev.location

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
    
  subnets = var.subnets
  nsgs    = var.nsgs
# nat_gateway_subnet_names = ["snet-aks"]
  tags = var.tags
}

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = "law-enterprise-dev"
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.common_tags
}

module "acr" {
  source = "../../modules/acr"

  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.dev.name
  location            = data.azurerm_resource_group.dev.location

  sku           = var.acr_sku
  admin_enabled = false

  tags = local.common_tags
}


module "key_vault" {
  source = "../../modules/key-vault"

  name                = var.key_vault_name
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = var.key_vault_sku

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  public_network_access_enabled = true

  tags = local.common_tags
}

module "managed_identity" {
  source = "../../modules/managed-identity"

  name                = var.managed_identity_name
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name

  tags = local.common_tags
}
module "aks" {
  source = "../../modules/aks"

  name                = var.aks_name
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name

  dns_prefix = var.aks_dns_prefix

  subnet_id = module.network.subnet_ids["snet-aks"]

  log_analytics_workspace_id = module.log_analytics.id

  node_count             = var.aks_node_count
  vm_size                = var.aks_vm_size
  application_gateway_id = module.application_gateway.id
  tags                   = local.common_tags
}

module "rbac" {
  source = "../../modules/rbac"

  acr_id                     = module.acr.id
  kubelet_identity_object_id = module.aks.kubelet_identity_object_id

  key_vault_id                  = module.key_vault.id
  managed_identity_principal_id = module.managed_identity.principal_id
}

module "sql" {

  source = "../../modules/sql"

  resource_group_name = data.azurerm_resource_group.dev.name
  location            = data.azurerm_resource_group.dev.location

  sql_server_name   = var.sql_server_name
  sql_database_name = var.sql_database_name

  administrator_login                  = var.sql_admin_username
  administrator_login_password         = var.sql_admin_password
  azuread_administrator_login_username = "Mahendra Rathore"
  azuread_administrator_object_id      = "c2e174c7-5f26-44f6-86f1-c27f00d00443"
  azuread_administrator_tenant_id      = "7fbcf046-0770-451c-a4d7-b52946f08e84"
  sku_name                             = var.sql_sku_name
  max_size_gb                          = var.sql_max_size_gb

  tags = local.common_tags
}

module "sql_private_dns" {

  source = "../../modules/private-dns"

  dns_zone_name = var.sql_private_dns_zone_name

  resource_group_name = data.azurerm_resource_group.dev.name

  vnet_id = module.network.vnet_id

  virtual_network_link_name = var.sql_private_dns_link_name

  tags = local.common_tags
}

module "sql_private_endpoint" {

  source = "../../modules/private-endpoint"

  name = var.sql_private_endpoint_name

  location = data.azurerm_resource_group.dev.location

  resource_group_name = data.azurerm_resource_group.dev.name

  subnet_id = module.network.subnet_ids["snet-private-endpoints"]

  private_connection_resource_id = module.sql.server_id

  subresource_names = ["sqlServer"]

  private_dns_zone_id = module.sql_private_dns.id

  tags = local.common_tags
}


module "storage" {

  source = "../../modules/storage"

  storage_account_name = var.storage_account_name

  resource_group_name = data.azurerm_resource_group.dev.name

  location = data.azurerm_resource_group.dev.location

  account_tier = var.storage_account_tier

  account_replication_type = var.storage_replication_type

  tags = local.common_tags
}

module "storage_private_dns" {

  source = "../../modules/private-dns"

  dns_zone_name = var.storage_private_dns_zone_name

  resource_group_name = data.azurerm_resource_group.dev.name

  vnet_id = module.network.vnet_id

  virtual_network_link_name = var.storage_private_dns_link_name

  tags = local.common_tags
}

module "storage_private_endpoint" {

  source = "../../modules/private-endpoint"

  name = var.storage_private_endpoint_name

  location = data.azurerm_resource_group.dev.location

  resource_group_name = data.azurerm_resource_group.dev.name

  subnet_id = module.network.subnet_ids["snet-private-endpoints"]

  private_connection_resource_id = module.storage.id

  subresource_names = [
    "blob"
  ]

  private_dns_zone_id = module.storage_private_dns.id

  tags = local.common_tags
}

module "appgw_public_ip" {
  source = "../../modules/public-ip"

  name = var.appgw_public_ip_name

  resource_group_name = data.azurerm_resource_group.dev.name

  location = data.azurerm_resource_group.dev.location

  tags = local.common_tags
}

module "waf" {
  source = "../../modules/waf"

  name = var.waf_policy_name

  resource_group_name = data.azurerm_resource_group.dev.name

  location = data.azurerm_resource_group.dev.location

  tags = local.common_tags
}


module "application_gateway" {
  source = "../../modules/application-gateway"

  name = var.application_gateway_name

  resource_group_name = data.azurerm_resource_group.dev.name

  location = data.azurerm_resource_group.dev.location

  subnet_id = module.network.subnet_ids["snet-appgw"]

  public_ip_id        = module.appgw_public_ip.id
  key_vault_id        = module.key_vault.id
  key_vault_secret_id = "https://kv-ent3tier-dev01.vault.azure.net/secrets/enterpriseapitask-tls"
  waf_policy_id       = module.waf.id
  agic_principal_id   = module.aks.agic_identity[0].ingress_application_gateway_identity[0].object_id
  tags                = local.common_tags
}
module "appgw_diagnostics" {
  source = "../../modules/diagnostic-settings"

  name = "diag-appgw-dev"

  target_resource_id = module.application_gateway.id

  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog"
  ]

  metric_categories = [
    "AllMetrics"
  ]
}

module "sql_diagnostics" {
  source = "../../modules/diagnostic-settings"

  name = "diag-sql-dev"

  target_resource_id = module.sql.database_id

  log_analytics_workspace_id = module.log_analytics.id

  log_categories = []

  metric_categories = [
    "Basic",
    "InstanceAndAppAdvanced",
    "WorkloadManagement"
  ]
}


module "key_vault_diagnostics" {
  source = "../../modules/diagnostic-settings"

  name = "diag-keyvault-dev"

  target_resource_id = module.key_vault.id

  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "AuditEvent"
  ]

  metric_categories = [
    "AllMetrics"
  ]
}
module "storage_diagnostics" {
  source = "../../modules/diagnostic-settings"

  name = "diag-storage-dev"

  target_resource_id = module.storage.id

  log_analytics_workspace_id = module.log_analytics.id

  log_categories = []

  metric_categories = [
    "Transaction",
    "Capacity"
  ]
}

module "aks_diagnostics" {
  source = "../../modules/diagnostic-settings"

  name = "diag-aks-dev"

  target_resource_id = module.aks.id

  log_analytics_workspace_id = module.log_analytics.id

  log_categories = []

  metric_categories = [
    "AllMetrics"
  ]
}

module "action_group" {
  source = "../../modules/action-group"

  name                = var.action_group_name
  resource_group_name = data.azurerm_resource_group.dev.name
  short_name          = var.action_group_short_name

  email_receiver_name    = "dev-alert-email"
  email_receiver_address = var.alert_email_address

  tags = local.common_tags
}

module "appgw_unhealthy_alert" {
  source = "../../modules/metric-alert"

  name = "alert-appgw-unhealthy-dev"

  resource_group_name = data.azurerm_resource_group.dev.name

  scopes = [
    module.application_gateway.id
  ]

  description = "Alert when Application Gateway has unhealthy backend hosts."

  severity = 2

  metric_namespace = "Microsoft.Network/applicationGateways"

  metric_name = "UnhealthyHostCount"

  aggregation = "Average"

  operator = "GreaterThan"

  threshold = 0

  action_group_id = module.action_group.id

  tags = local.common_tags
}

module "sql_cpu_alert" {
  source = "../../modules/metric-alert"

  name = "alert-sql-cpu-dev"

  resource_group_name = data.azurerm_resource_group.dev.name

  scopes = [
    module.sql.database_id
  ]

  description = "Alert when Azure SQL CPU utilization is high."

  severity = 2

  metric_namespace = "Microsoft.Sql/servers/databases"

  metric_name = "cpu_percent"

  aggregation = "Average"

  operator = "GreaterThan"

  threshold = 80

  action_group_id = module.action_group.id

  tags = local.common_tags
}

module "storage_availability_alert" {
  source = "../../modules/metric-alert"

  name = "alert-storage-availability-dev"

  resource_group_name = data.azurerm_resource_group.dev.name

  scopes = [
    module.storage.id
  ]

  description = "Alert when Storage Account availability falls below the expected level."

  severity = 2

  metric_namespace = "Microsoft.Storage/storageAccounts"

  metric_name = "Availability"

  aggregation = "Average"

  operator = "LessThan"

  threshold = 99

  action_group_id = module.action_group.id

  tags = local.common_tags
}