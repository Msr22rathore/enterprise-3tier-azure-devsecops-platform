variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "sql_server_name" {
  description = "SQL Server Name"
  type        = string
}

variable "sql_database_name" {
  description = "SQL Database Name"
  type        = string
}

variable "administrator_login" {
  description = "SQL Administrator Login"
  type        = string
}

variable "administrator_login_password" {
  description = "SQL Administrator Password"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SQL Database SKU"
  type        = string
  default     = "Basic"
}

variable "max_size_gb" {
  description = "Database Size"
  type        = number
  default     = 2
}

variable "tags" {
  type = map(string)
}

variable "azuread_administrator_login_username" {
  type = string
}

variable "azuread_administrator_object_id" {
  type = string
}

variable "azuread_administrator_tenant_id" {
  type = string
}