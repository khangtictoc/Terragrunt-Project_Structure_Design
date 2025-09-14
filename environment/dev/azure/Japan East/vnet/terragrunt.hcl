include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}



# Use self-developed modules
# terraform {
#     source = "../../../../../modules/azure/vnet"
# }

# ┌──────────────────────────────────────────────────────────────────┐ 
# │                                                                  │
# │    Self-developed  Module - Terraform HashiCorp Registry         │ 
# │                                                                  │
# └──────────────────────────────────────────────────────────────────┘

# Use self-developed modules
terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/azure/vnet.git"
}

locals {
  name     = "testproject-${local.env}"
  env      = include.root.locals.env
  region   = include.root.locals.region
  tags     = include.root.locals.tags
}

inputs = {
  vnet = {
    enabled             = true
    create_resource_group = true
    name                = local.name
    location            = local.region
    resource_group_name = "sample-labs"
    address_space       = ["10.0.0.0/16"]
    
    subnets = [
      {
        name             = "subnet1"
        address_prefixes = ["10.0.1.0/24"]
      },
      {
        name             = "subnet2"
        address_prefixes = ["10.0.2.0/24"]
      }
    ]

    tags = local.tags
  }
  
}

