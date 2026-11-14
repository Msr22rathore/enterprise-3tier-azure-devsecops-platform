resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each = var.nsgs

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.nsgs

  subnet_id = azurerm_subnet.this[
    each.value.subnet_name
  ].id

  network_security_group_id = azurerm_network_security_group.this[
    each.key
  ].id
}




# resource "azurerm_public_ip" "nat" {
#   name                = "${var.vnet_name}-nat-pip"
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   allocation_method = "Static"
#   sku               = "Standard"

#   tags = var.tags
# }

# resource "azurerm_nat_gateway" "this" {
#   name                = "${var.vnet_name}-nat"
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   sku_name            = "Standard"
#   idle_timeout_in_minutes = 10

#   tags = var.tags
# }

# resource "azurerm_nat_gateway_public_ip_association" "this" {
#   nat_gateway_id       = azurerm_nat_gateway.this.id
#   public_ip_address_id = azurerm_public_ip.nat.id
# }

# resource "azurerm_subnet_nat_gateway_association" "this" {
#   for_each = toset(var.nat_gateway_subnet_names)

#   subnet_id      = azurerm_subnet.this[each.value].id
#   nat_gateway_id = azurerm_nat_gateway.this.id
# }