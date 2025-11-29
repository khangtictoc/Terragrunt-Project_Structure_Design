include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "mapping_conventions" {
  path   = find_in_parent_folders("mapping_conventions.hcl")
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
  source = "git::https://gitlab.com/terraform-modules7893436/hcp/vault-components.git"
}

dependency "k8s_cluster" {
  config_path = "../../../aws/${local.region}/eks"
  mock_outputs = {
    name = "test"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "vault_dedicated_cluster" {
  config_path = "../vault-dedicated-cluster"

  mock_outputs = {
    admin_token      = "fake-token"
    public_endpoint  = "https://my-vault-public:8200"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  arg_masks     = include.root.locals.arg_masks
  region   = include.root.locals.region
}

inputs = yamldecode(
  templatefile("../config.yaml", merge(
    local.arg_masks,
    {
      region = local.region
      vault_cluster__address = dependency.vault_dedicated_cluster.outputs.public_endpoint
      vault_cluster__admin_token = dependency.vault_dedicated_cluster.outputs.admin_token
      k8s_cluster__name = dependency.k8s_cluster.outputs.name
    }
  ))
).vault_component_list.main
