variable "vnet" {
  description = "Virtual network configuration"
  type = object({
    enabled             = bool
    name                = string
    location            = string
    resource_group_name = string
    address_space       = list(string)
    tags                = map(string)
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
    }))
  })
}