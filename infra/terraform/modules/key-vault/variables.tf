variable "name" {
  description = "Name of the Azure Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region where Key Vault will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days deleted Key Vault objects are retained."
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for the Key Vault."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access to Key Vault is enabled."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Key Vault."
  type        = map(string)
  default     = {}
}