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
  source = "tfr:///terraform-aws-modules/security-group/aws?version=5.3.0"
}

locals {
  name     = "test--allow-all-${local.env}"
  env      = include.root.locals.env
  tags     = include.root.locals.tags
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name        = local.name
  description = "[Testing] Allow all traffic"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = local.tags
}

