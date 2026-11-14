variable "name" {
  description = "Application Gateway name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Application Gateway subnet ID"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP resource ID"
  type        = string
}

variable "waf_policy_id" {
  description = "WAF Policy resource ID"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}
variable "key_vault_id" {
  description = "Key Vault resource ID used by Application Gateway"
  type        = string
}

variable "key_vault_secret_id" {
  description = "Key Vault resource ID used by Application Gateway"
  type        = string
}
variable "agic_principal_id" {
  description = "Principal ID of the AGIC managed identity"
  type        = string
}