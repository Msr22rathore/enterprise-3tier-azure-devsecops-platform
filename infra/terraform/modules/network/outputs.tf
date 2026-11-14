output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map containing subnet names and their resource IDs"

  value = {
    for name, subnet in azurerm_subnet.this :
    name => subnet.id
  }
}

output "nsg_ids" {
  description = "Map containing NSG names and their resource IDs"

  value = {
    for name, nsg in azurerm_network_security_group.this :
    name => nsg.id
  }
}