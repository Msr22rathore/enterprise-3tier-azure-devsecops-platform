variable "name" {
  description = "Action Group name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "short_name" {
  description = "Short name for the Action Group"
  type        = string
  default     = "entdev"
}

variable "email_receiver_name" {
  description = "Email receiver name"
  type        = string
}

variable "email_receiver_address" {
  description = "Email address for alert notifications"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}