variable "resource_group_name" {
  description = "Existing DEV Resource Group"
  type        = string
}
variable "environment" {
  description = "Deployment environment such as dev, test, or prod."
  type        = string
}

variable "project_name" {
  description = "Name of the project used for resource naming and tagging."
  type        = string
}

variable "vnet_name" {
  description = "DEV Virtual Network name"
  type        = string
}

variable "vnet_address_space" {
  description = "DEV VNet address space"
  type        = list(string)
}

variable "subnets" {
  description = "DEV subnet configuration"

  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "nsgs" {
  description = "DEV NSGs and subnet associations"

  type = map(object({
    subnet_name = string
  }))

  default = {}
}

variable "tags" {
  description = "Common DEV resource tags"
  type        = map(string)
  default     = {}
}
variable "acr_name" {
  description = "Name of the development Azure Container Registry."
  type        = string
}

variable "acr_sku" {
  description = "SKU of the development Azure Container Registry."
  type        = string
  default     = "Basic"
}

variable "key_vault_name" {
  description = "Name of the development Key Vault."
  type        = string
}

variable "key_vault_sku" {
  description = "SKU of the development Key Vault."
  type        = string
  default     = "standard"
}

variable "managed_identity_name" {
  type        = string
  description = "Name of the application managed identity."
}

variable "aks_name" {
  type        = string
  description = "Name of the AKS cluster."
}

variable "aks_dns_prefix" {
  type        = string
  description = "DNS prefix for AKS."
}

variable "aks_node_count" {
  type    = number
  default = 1
}

variable "aks_vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}
variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "sql_sku_name" {
  type    = string
  default = "Basic"
}

variable "sql_max_size_gb" {
  type    = number
  default = 2
}

variable "sql_private_dns_zone_name" {
  type    = string
  default = "privatelink.database.windows.net"
}

variable "sql_private_dns_link_name" {
  type    = string
  default = "sql-vnet-link"
}

variable "sql_private_endpoint_name" {
  type    = string
  default = "pep-sql-dev"
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}

variable "storage_private_dns_zone_name" {
  description = "Storage Blob Private DNS Zone"
  type        = string
}

variable "storage_private_dns_link_name" {
  description = "Storage VNet Link Name"
  type        = string
}

variable "storage_private_endpoint_name" {
  description = "Storage Private Endpoint Name"
  type        = string
}

variable "appgw_public_ip_name" {
  description = "Application Gateway Public IP name"
  type        = string
}

variable "waf_policy_name" {
  description = "WAF Policy name"
  type        = string
}

variable "application_gateway_name" {
  description = "Application Gateway name"
  type        = string
}

variable "action_group_name" {
  description = "Azure Monitor Action Group name"
  type        = string
  default     = "ag-enterprise-dev"
}

variable "action_group_short_name" {
  description = "Azure Monitor Action Group short name"
  type        = string
  default     = "entdev"
}

variable "alert_email_address" {
  description = "Email address for Azure Monitor alerts"
  type        = string
  sensitive   = true
}
# variable "nat_gateway_subnet_names" {
#   type        = set(string)
#   description = "Subnet names to associate with the NAT Gateway."
#   default     = []
# }
