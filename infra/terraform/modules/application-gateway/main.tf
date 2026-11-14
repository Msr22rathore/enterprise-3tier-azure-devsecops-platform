data "azurerm_client_config" "current" {}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
identity {
  type = "UserAssigned"

  identity_ids = [
    azurerm_user_assigned_identity.appgw.id
  ]
}


  http2_enabled = true

  firewall_policy_id = var.waf_policy_id

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  # frontend_port {
  #   name = "http-port"
  #   port = 80
  # }
  frontend_port {
  name = "https-port"
  port = 443
  }
  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = var.public_ip_id
  }
  
  # ADD THIS HERE
  ssl_certificate {
    name                = "enterpriseapitask-tls"
    key_vault_secret_id = var.key_vault_secret_id
  }
  backend_address_pool {
    name = "aks-backend-pool"
  }

  backend_http_settings {
    name                  = "aks-http-settings"
    cookie_based_affinity = "Disabled"

    port     = 80
    protocol = "Http"

    request_timeout = 60
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "enterpriseapitask-tls"
  }

  # request_routing_rule {
  #   name                       = "http-routing-rule"
  #   priority                   = 100
  #   rule_type                  = "Basic"

  #   http_listener_name         = "http-listener"
  #   backend_address_pool_name  = "aks-backend-pool"
  #   backend_http_settings_name = "aks-http-settings"
  # }

  request_routing_rule {
  name                       = "https-routing-rule"
  priority                   = 110
  rule_type                  = "Basic"

  http_listener_name         = "https-listener"
  backend_address_pool_name  = "aks-backend-pool"
  backend_http_settings_name = "aks-http-settings"
}

  tags = var.tags



   lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      tags,
    ]
}
}

resource "azurerm_user_assigned_identity" "appgw" {
  name                = "id-appgw-enterprise-dev"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}
resource "azurerm_role_assignment" "appgw_keyvault_secrets" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appgw.principal_id
}
resource "azurerm_role_assignment" "agic_managed_identity_operator" {
  scope                = azurerm_user_assigned_identity.appgw.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.agic_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "agic_resource_group_reader" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = var.agic_principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "agic_appgw_contributor" {
  scope                = azurerm_application_gateway.this.id
  role_definition_name = "Contributor"
  principal_id         = var.agic_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "agic_appgw_subnet_network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = var.agic_principal_id
  principal_type       = "ServicePrincipal"
}