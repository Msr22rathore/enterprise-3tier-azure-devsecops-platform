variable "name" {
  description = "Metric alert name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "scopes" {
  description = "Resource IDs monitored by the alert"
  type        = list(string)
}

variable "description" {
  description = "Alert description"
  type        = string
}

variable "severity" {
  description = "Alert severity from 0 to 4"
  type        = number
  default     = 2
}

variable "frequency" {
  description = "Alert evaluation frequency"
  type        = string
  default     = "PT5M"
}

variable "window_size" {
  description = "Alert evaluation window"
  type        = string
  default     = "PT5M"
}

variable "metric_namespace" {
  description = "Azure Monitor metric namespace"
  type        = string
}

variable "metric_name" {
  description = "Azure Monitor metric name"
  type        = string
}

variable "aggregation" {
  description = "Metric aggregation"
  type        = string
  default     = "Average"
}

variable "operator" {
  description = "Metric comparison operator"
  type        = string
  default     = "GreaterThan"
}

variable "threshold" {
  description = "Metric threshold"
  type        = number
}

variable "action_group_id" {
  description = "Azure Monitor Action Group ID"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}