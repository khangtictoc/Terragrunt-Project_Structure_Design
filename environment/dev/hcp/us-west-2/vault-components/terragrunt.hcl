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
  source = "git::https://gitlab.com/terraform-modules7893436/hcp/vault-components.git"
}

dependency "vault_dedicated_cluster" {
  config_path = "../vault-dedicated-cluster"

  mock_outputs = {
    k8s_path          = "kubernetes"
    public_endpoint  = "https://my-vault-public:8200"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  arg_masks     = include.root.locals.arg_masks
}

inputs = yamldecode(
  templatefile("../config.yaml", merge(
    local.arg_masks,
    {
      vault_cluster__address = dependency.vault_dedicated_cluster.outputs.public_endpoint
      vault_cluster__k8s_path = dependency.vault_dedicated_cluster.outputs.k8s_path
    }
  ))
).vault_component_list.main
