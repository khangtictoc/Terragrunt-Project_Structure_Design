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
  source = "git::https://gitlab.com/terraform-modules7893436/aws/eks.git?ref=main"
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
    subnet_names_to_ids_mapping = {
      application-a       = "subnet-00a8a9ced4a593f88"
      application-b       = "subnet-00a8a9ced4a593f87"
      network-appliance-a = "subnet-00a8a9ced4a593f86"
      network-appliance-b = "subnet-00a8a9ced4a593f85"
    }
    vpc_id = "vpc-0a1b2c3d4e5f6g7h8"
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
        nat_gateway_subnet_id = dependency.vpc.outputs.public_subnet_names_to_attributes["network-appliance-a"].id
      }
    ))
  ).eks.main,
  {
    vpc_config = 
      control_plane_subnets = {
        dependency.vpc.outputs.public_subnet_names_to_attributes["network-appliance-a"],
        dependency.vpc.outputs.public_subnet_names_to_attributes["network-appliance-b"]
      }

      node_groups_subnets = {
        dependency.vpc.outputs.private_subnet_names_to_attributes["application-a"],
        dependency.vpc.outputs.private_subnet_names_to_attributes["application-b"]
      }

      vpc_id                   = dependency.vpc.outputs.vpc_id
      endpoint_public_access   = true
    
    
    tags = local.tags
  }
)

