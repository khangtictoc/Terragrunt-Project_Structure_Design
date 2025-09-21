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
  source = "git::https://gitlab.com/terraform-modules7893436/azure/aks.git"
}

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    aks_cluster_name = "DEV-TESTPROJECT-GENERAL-00"
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
  kubeconfig_output_path = "${local.root_folder_path}/output/${local.env}/${local.platform}/${local.region}/kubeconfig"

  env      = include.root.locals.env
  region   = include.root.locals.region
  platform = include.root.locals.platform
  tags     = include.root.locals.tags
  root_folder_path = include.root.locals.root_folder_path
}

inputs = {
  aks = {
    created = true
    kubeconfig_output_path = local.kubeconfig_output_path
    name                = dependency.naming.outputs.aks_cluster_name
    nodepool_temporary_name_for_rotation = "temp"
    location            =  local.region
    resource_group_name = dependency.naming.outputs.resource_group_name

    vnet_subnet_id = dependency.vnet.outputs.subnet_ids.subnet2
    dns_prefix          = "exampleaks1"
    network_profile = {
      network_plugin = "azure"
      network_plugin_mode = "overlay"
      pod_cidr = "10.0.128.0/18"
      service_cidr = "10.0.192.0/18"
      dns_service_ip = "10.0.192.10"
    }

    kubernetes_version  = "1.32.6"

    default_node_pool = {
      name       = "default"
      node_count = 1
      vm_size    = "Standard_B2pls_v2"
    }
    cluster_node_pool = [
      {
        name       = "frontend"
        node_count = 1
        vm_size    = "Standard_B2pls_v2"
      },
      {
        name       = "backend"
        node_count = 1
        vm_size    = "Standard_B2pls_v2"
      }
    ] 
    tags = local.tags
  }
}

