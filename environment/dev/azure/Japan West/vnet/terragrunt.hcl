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

# ---- DEPENDENCIES ----

dependency "resource_group" {
  config_path  = "../rg"
  skip_outputs = true
}

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    vnet_name           = "test"
    resource_group_name = "test"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  env    = include.root.locals.env
  region = include.root.locals.region
  tags   = include.root.locals.tags

  arg_masks = include.root.locals.arg_masks
}

inputs = merge(
  yamldecode(
    templatefile("../config.yaml", merge(
      local.arg_masks,
      {
        region       = local.region
        vnet_name    = dependency.naming.outputs.vnet_name
        vnet_rg_name = dependency.naming.outputs.resource_group_name
      }
    ))
  ).vnets.main,
  {
    tags = local.tags
  }
)

