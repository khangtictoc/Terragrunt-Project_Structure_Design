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
  mock_outputs = {
    subnet_ids = {
      "subnet1" = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue",

      "subnet2" = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue"
    }
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  region   = include.root.locals.region
  tags     = include.root.locals.tags
}

inputs = {
  appgw = {
    created = true
    name = dependency.naming.outputs.appgw_name
    resource_group_name = dependency.naming.outputs.resource_group_name
    location = local.region

    backend_address_pool = {}
    backend_http_settings = {
      cookie_based_affinity = "Disabled"
      path                  = "/path1/"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
    }

    frontend_ip_configuration = {}
    frontend_port = {
      port = 80
    }

    gateway_ip_configuration = {
      subnet_id = dependency.vnet.outputs.subnet_ids.subnet1
    }

    http_listener = {
      protocol              = "Http"
    }

    request_routing_rule = {
      rule_type = "Basic"
      priority = 1
    }

    sku = {
      name = "Basic"
      tier = "Basic"
      capacity = 1
    }

    tags = local.tags
  }
}

