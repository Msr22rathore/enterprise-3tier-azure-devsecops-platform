variable "name" {
  type        = string
  description = "AKS cluster name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group containing AKS."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for AKS."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID used by AKS nodes."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace resource ID."
}

variable "node_count" {
  type        = number
  description = "Initial number of system nodes."
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "VM size for the system node pool."
  default     = "Standard_D2s_v5"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "application_gateway_id" {
  type        = string
  description = "Resource ID of the Application Gateway used by AGIC."
  default     = null
}