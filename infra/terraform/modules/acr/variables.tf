variable "name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where ACR will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region where ACR will be deployed."
  type        = string
}

variable "sku" {
  description = "SKU of the Azure Container Registry."
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Enable or disable the ACR local admin account."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the ACR."
  type        = map(string)
  default     = {}
}