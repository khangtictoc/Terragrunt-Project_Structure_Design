include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}



# Use self-developed modules
# terraform {
#     source = "../../../../../modules/azure/vnet"
# }

# ┌──────────────────────────────────────────────────────────────────┐ 
# │                                                                  │
# │    Self-developed  Module - Terraform HashiCorp Registry         │ 
# │                                                                  │
# └──────────────────────────────────────────────────────────────────┘

# Use self-developed modules
terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/aws/eks.git?ref=feat/add-cleanup-eks-script"
}

# ---- DEPENDENCIES ----

dependency "naming" {
  config_path = "../naming"
  mock_outputs = {
    aws = {
      eks_cluster_name = "test"
      vpc_name         = "test"
    }
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    public_subnets_ids = ["subnet-12345678", "subnet-87654321"]
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

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
        eks_name = dependency.naming.outputs.aws.eks_cluster_name
        vpc_name = dependency.naming.outputs.aws.vpc_name
      }
    ))
  ).eks.main,
  {
    tags = local.tags
  }
)

