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

locals {
  name     = "testproject-${local.env}"
  kubeconfig_output_path = "${local.root_folder_path}/output/dev/azure/Korea South/kubeconfig"

  env      = include.root.locals.env
  region   = include.root.locals.region
  tags     = include.root.locals.tags
  root_folder_path = include.root.locals.root_folder_path
}

inputs = {
  aks = {
    created = true
    kubeconfig_output_path = local.kubeconfig_output_path
    name                = local.name
    location            =  local.region
    resource_group_name = "sample-labs"
    dns_prefix          = "exampleaks1"
    kubernetes_version  = "1.32.6"

    default_node_pool = {
      name       = "default"
      temporary_name_for_rotation  = "temp"
      node_count = 1
      vm_size    = "Standard_D2ls_v5"
    }
    cluster_node_pool = [
      {
        name       = "frontend"
        node_count = 1
        vm_size    = "Standard_D2ls_v5"
      },
      {
        name       = "backend"
        node_count = 1
        vm_size    = "Standard_D2ls_v5"
      }
    ] 
    tags = local.tags
  }
}

