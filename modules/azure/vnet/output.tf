output "vnet_id" {
  description = "The ID of the virtual network"
  value       = try(azurerm_virtual_network.vnet[0].id, data.azurerm_virtual_network.existing[0].id)
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = try(azurerm_virtual_network.vnet[0].name, data.azurerm_virtual_network.existing[0].name)
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    for name, subnet in azurerm_subnet.subnet : name => subnet.id
  }
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = try(azurerm_resource_group.rg[0].id, data.azurerm_resource_group.existing[0].id)
}