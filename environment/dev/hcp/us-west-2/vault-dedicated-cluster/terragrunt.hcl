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
    }
  }
}

