variable "name" {
  description = "Diagnostic setting name"
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID for which diagnostics should be enabled"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID"
  type        = string
}

variable "log_categories" {
  description = "Diagnostic log categories to enable"
  type        = list(string)
  default     = []
}

variable "metric_categories" {
  description = "Diagnostic metric categories to enable"
  type        = list(string)
  default     = []
}