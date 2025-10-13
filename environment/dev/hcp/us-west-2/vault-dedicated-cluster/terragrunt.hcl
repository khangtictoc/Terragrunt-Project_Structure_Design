include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Use self-developed modules
# terraform {
#     source = "../../../../../modules/aws/vpc"
# }

# ┌──────────────────────────────────────┐
# │                                      │
# │    Use Official  Community Module    │
# │                                      │
# └──────────────────────────────────────┘

terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/hcp/vault-dedicated-cluster.git"
}

dependency "aks" {
  config_path = "../../../azure/Japan East/aks"
  mock_outputs = {
    cluster_name        = "DEV-TESTPROJECT-GENERAL-00"
    resource_group_name = "DEV-TESTPROJECT-GENERAL-00"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  name     = "testproject-${local.env}"
  env      = include.root.locals.env
  region   = include.root.locals.region
}

inputs = {
  vault_dedicated_cluster = {
    is_created = true
    hvn = {
      enable_peering  = false
      id             = "${local.name}"
      cidr_block     = ""
      route_id       = "${local.name}"
      region         = "${local.region}"
      cloud_provider = "aws"
    }
    cluster = {
      id         = "${local.name}"
      peering_id = "${local.name}"
      tier       = "dev"
      public_endpoint = true
      auth_method_list = [
        "kubernetes"
      ]
      kubernetes_cluster_list = {
        "DEV-TESTPROJECT-GENERAL-00" = {
          resource_group     = dependency.aks.outputs.resource_group_name
        }
      }
    }
  }
}

