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

  arg_masks     = include.root.locals.arg_masks
}

inputs = merge(
  yamldecode(
    templatefile("../config.yaml", merge(
      local.arg_masks,
      {
        region = local.region
        vnet_name   = dependency.naming.outputs.vnet_name
        vnet__rg_name = dependency.naming.outputs.resource_group_name
      }
    ))
  ).vnet_list.main,
  {
    tags = local.tags
  }
)

