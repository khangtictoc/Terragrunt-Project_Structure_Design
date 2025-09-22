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

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    vnet_name = "DEV-TESTPROJECT-GENERAL-00"
    resource_group_name = "DEV-TESTPROJECT-GENERAL-00"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  env      = include.root.locals.env
  region   = include.root.locals.region
  tags     = include.root.locals.tags
}

inputs = {
  vnet = {
    enabled             = true
    create_resource_group = true
    name                = dependency.naming.outputs.vnet_name
    location            = local.region
    resource_group_name = dependency.naming.outputs.resource_group_name
    address_space       = ["10.0.0.0/16"]
    
    subnets = [
      {
        name             = "network_appliances"
        address_prefixes = ["10.0.0.0/24"]
      },
      {
        name             = "workloads"
        address_prefixes = ["10.0.64.0/18"]
      }
    ]

    tags = local.tags
  }
  
}

