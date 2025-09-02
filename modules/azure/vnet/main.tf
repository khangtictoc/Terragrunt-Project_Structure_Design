# Check if resource group exists
data "azurerm_resource_group" "existing" {
  count = var.vnet.enabled ? 1 : 0
  name  = var.vnet.resource_group_name
}

# Create resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  count = var.vnet.enabled && can(data.azurerm_resource_group.existing[0].name) == false ? 1 : 0

  name     = var.vnet.resource_group_name
  location = var.vnet.location
  tags     = var.vnet.tags
}

# Check if VNET exists
data "azurerm_virtual_network" "existing" {
  count               = var.vnet.enabled ? 1 : 0
  name                = var.vnet.name
  resource_group_name = var.vnet.resource_group_name

  depends_on = [azurerm_resource_group.rg]
}

# Create VNET if it doesn't exist
resource "azurerm_virtual_network" "vnet" {
  count = var.vnet.enabled && can(data.azurerm_virtual_network.existing[0].name) == false ? 1 : 0

  name                = var.vnet.name
  location            = var.vnet.location
  resource_group_name = var.vnet.resource_group_name
  address_space       = var.vnet.address_space
  tags                = var.vnet.tags

  depends_on = [azurerm_resource_group.rg]
}

# Check if subnets exist
data "azurerm_subnet" "existing" {
  for_each = {
    for subnet in var.vnet.subnets : subnet.name => subnet
    if var.vnet.enabled
  }

  name                 = each.value.name
  virtual_network_name = var.vnet.name
  resource_group_name  = var.vnet.resource_group_name

  depends_on = [azurerm_virtual_network.vnet]
}

# Create subnets that don't exist
resource "azurerm_subnet" "subnet" {
  for_each = {
    for subnet in var.vnet.subnets : subnet.name => subnet
    if var.vnet.enabled && can(data.azurerm_subnet.existing[subnet.name].name) == false
  }

  name                 = each.value.name
  resource_group_name  = var.vnet.resource_group_name
  virtual_network_name = var.vnet.name
  address_prefixes     = each.value.address_prefixes
  
  depends_on = [azurerm_virtual_network.vnet]
}