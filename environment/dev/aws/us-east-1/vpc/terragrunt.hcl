# --- HEADERS --------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# --- IMPORT MODULES --------------------

## [1] -> Use self-developed modules

# terraform {
#     source = "../../../../../modules/aws/vpc"
# }

## [2] -> Use remote modules (Community, Gitlab, Github, etc.)

terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/aws/vpc.git?ref=main"
}

# --- DEPENDENCIES --------------------

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    aws = {
      vpc_names = {
        general = "sample-vpc-name"
      }
    }
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

# --- INPUT VALUES --------------------

locals {
  region    = include.root.locals.region
  tags      = include.root.locals.tags
  arg_masks = include.root.locals.arg_masks
}

inputs = merge(
  yamldecode(
    templatefile("../config.yaml", merge(
      local.arg_masks,
      {
        region   = local.region
        vpc_name = dependency.naming.outputs.aws.vpc_names["general"]
        tags     = local.tags
      }
    ))
  ).vpc.main,
  {
    tags = local.tags
  }
)

