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
  source = "git::https://gitlab.com/terraform-modules7893436/kubernetes-deploy/argocd.git"
}

dependency "k8s_cluster" {
  config_path = "../../../../${local.platform}/${local.region}/${local.cluster_type}"
}

locals {
  env      = include.root.locals.env
  region   = include.root.locals.region
  platform = include.root.locals.platform
  cluster_type = lookup(include.mapping_conventions.locals.cluster_type, local.platform, "")
}

inputs = {}

