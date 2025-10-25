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
}

locals {
  name     = "testproject-${local.env}"
  env      = include.root.locals.env
  region   = include.root.locals.region

  rendered_yaml = templatefile("../${local.region}.yaml.tpl", {
    region = local.region
    hvn_id = "hvn-${local.name}"
    cluster_id = "vault-${local.name}"
    route_id = "route-${local.name}"
  })
}

inputs = yamldecode(templatefile("../${local.region}.yaml.tpl", {
    region = local.region
    hvn_id = "hvn-${local.name}"
    cluster_id = "vault-${local.name}"
    route_id = "route-${local.name}"
  })
).vault_dedicated_cluster_list.main