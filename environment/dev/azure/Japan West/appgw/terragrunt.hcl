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
  source = "git::https://gitlab.com/terraform-modules7893436/azure/appgw.git?ref=master"
}

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    appgw_name          = "DEV-TESTPROJECT-GENERAL-00"
    resource_group_name = "DEV-TESTPROJECT-GENERAL-00"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "vnet" {
  config_path = "../vnet"
  mock_outputs = {
    vnet_id = "/subscriptions/ca86aa0e-30d0-4a23-b1ac-3435fd053c42/resourceGroups/DEV-TESTPROJECT-GENERAL-00/providers/Microsoft.Network/virtualNetworks/DEV-TESTPROJECT-GENERAL-00"
    subnet_ids = {
      "network_appliances" = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue",
      "workloads"          = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue"
    }
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  region = include.root.locals.region
  tags   = include.root.locals.tags

  arg_masks = include.root.locals.arg_masks
}

inputs = merge(
  yamldecode(
    templatefile("../config.yaml", merge(
      local.arg_masks,
      {
        region                         = local.region
        appgw_name                     = dependency.naming.outputs.appgw_name
        appgw_rg_name                  = dependency.naming.outputs.resource_group_name
        appgw_gateway_ip_configuration = dependency.vnet.outputs.subnet_ids.network_appliances
      }
    ))
  ).application_gateways.main,
  {
    tags = local.tags
  }
)
