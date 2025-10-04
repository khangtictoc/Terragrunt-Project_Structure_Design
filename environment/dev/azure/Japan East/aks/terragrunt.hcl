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
    vnet_id = "/subscriptions/ca86aa0e-30d0-4a23-b1ac-3435fd053c42/resourceGroups/DEV-TESTPROJECT-GENERAL-00/providers/Microsoft.Network/virtualNetworks/DEV-TESTPROJECT-GENERAL-00"
    subnet_ids = {
      "network_appliances" = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue",
      "workloads" = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue"
    }
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "aks_appgw" {
  config_path = "../appgw"
  mock_outputs = {
    id = "/subscriptions/subid/resourceGroups/rg1/providers/Microsoft.Network/applicationGateways/appgw"
    public_ips = [
      "/subscriptions/ca86aa0e-30d0-4a23-b1ac-3435fd053c42/resourceGroups/DEV-TESTPROJECT-GENERAL-00/providers/Microsoft.Network/publicIPAddresses/DEV-TESTPROJECT-GENERAL-00",
      "/subscriptions/ca86aa0e-30d0-4a23-b1ac-3435fd053c42/resourceGroups/DEV-TESTPROJECT-GENERAL-00/providers/Microsoft.Network/publicIPAddresses/DEV-TESTPROJECT-GENERAL-00"
    ]
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

    vnet_subnet_id = dependency.vnet.outputs.subnet_ids.workloads
    dns_prefix          = "exampleaks1"
    network_profile = {
      network_plugin = "azure"
      network_plugin_mode = "overlay"
      pod_cidr = "10.0.128.0/18"
      service_cidr = "10.0.192.0/18"
      dns_service_ip = "10.0.192.10"
    }
    ingress_application_gateway = {
      gateway_id = dependency.aks_appgw.outputs.id
      vnet_id = dependency.vnet.outputs.vnet_id
      public_ip_ids = dependency.aks_appgw.outputs.public_ips
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

