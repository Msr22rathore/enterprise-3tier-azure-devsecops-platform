variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group"
  type        = string
}




variable "location" {
  description = "Azure region where networking resources will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space assigned to the Virtual Network"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create"

  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "nsgs" {
  description = "Map of Network Security Groups and their target subnets"

  type = map(object({
    subnet_name = string
  }))

  default = {}
}

variable "tags" {
  description = "Common tags applied to networking resources"
  type        = map(string)
  default     = {}
}
# variable "nat_gateway_subnet_names" {
#   type        = set(string)
#   description = "Subnet names to associate with the NAT Gateway."
#   default     = []
# }