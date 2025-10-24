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
  config_path = "../../../azure/Japan West/aks"
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
  cluster_defaults = yamldecode(file("../${local.region}.yaml"))
}

inputs = merge(
  local.cluster_defaults.vault_dedicated_cluster,
  {
    vault_dedicated_cluster = {
      created = true
      hvn = {
        id       = local.name
        route_id = local.name
        region   = local.region
      }
      cluster = {
        id         = local.name
        peering_id = local.name
        kubernetes_cluster_list = [
          {
            name            = dependency.aks.outputs.cluster_name
            resource_group  = dependency.aks.outputs.resource_group_name
          }
        ]
      }
    }
  }
)

