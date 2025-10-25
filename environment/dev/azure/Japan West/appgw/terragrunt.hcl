include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}



# Use self-developed modules
# terraform {
#     source = "../../../../../modules/azure/aks"
# }

# ┌──────────────────────────────────────────────────────────────────┐ 
# │                                                                  │
# │    Self-developed  Module - Terraform HashiCorp Registry         │ 
# │                                                                  │
# └──────────────────────────────────────────────────────────────────┘

# Use self-developed modules
terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/azure/appgw.git"
}

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    appgw_name = "DEV-TESTPROJECT-GENERAL-00"
    resource_group_name = "DEV-TESTPROJECT-GENERAL-00"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "vnet" {
  config_path = "../vnet"
}

locals {
  region   = include.root.locals.region
  tags     = include.root.locals.tags
}

inputs = merge(
  yamldecode(
    templatefile("../${local.region}.yaml.tpl", {
      region = local.region
      appgw_name   = dependency.naming.outputs.appgw_name
      appgw__rg_name = dependency.naming.outputs.resource_group_name
      appgw__gateway_ip_configuration = dependency.vnet.outputs.subnet_ids.network_appliances
    })
  ).application_gateway_list.main,
  {
    tags = local.tags
  }
)
