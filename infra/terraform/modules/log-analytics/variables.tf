variable "name" {
  description = "Name of the Log Analytics Workspace."
  type        = string
}

variable "location" {
  description = "Azure region where the workspace will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the workspace."
  type        = string
}

variable "sku" {
  description = "Log Analytics Workspace SKU."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Number of days to retain Log Analytics data."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}
}