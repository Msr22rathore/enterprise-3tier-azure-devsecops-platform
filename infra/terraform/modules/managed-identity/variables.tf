variable "name" {
  description = "Name of the user-assigned managed identity."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}