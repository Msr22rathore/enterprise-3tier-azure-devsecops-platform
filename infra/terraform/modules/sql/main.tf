resource "azurerm_mssql_server" "this" {

  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
azuread_administrator {
  login_username = var.azuread_administrator_login_username
  object_id      = var.azuread_administrator_object_id
  tenant_id      = var.azuread_administrator_tenant_id
}
  version = "12.0"

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  minimum_tls_version = "1.2"

  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {

  name      = var.sql_database_name
  server_id = azurerm_mssql_server.this.id

  sku_name = var.sku_name

  max_size_gb = var.max_size_gb

  zone_redundant = false

  tags = var.tags
}