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

    public_subnet_names_to_attributes = {
      application-a = {
        id = "subnet-0e635f742797c139d",
        route_table_id = "rtb-00b27ff5786bb4895"
      },
      application-b = {
        id = "subnet-075909145785d0e2a",
        route_table_id = "rtb-00b27ff5786bb4895"
      }
    }

    private_subnet_names_to_attributes = {
      application-a = {
        id = "subnet-0a1b2c3d4e5f6g7h8",
        route_table_id = "rtb-0a1b2c3d4e5f6g7h8"
      },
      application-b = {
        id = "subnet-1a2b3c4d5e6f7g8h9",
        route_table_id = "rtb-1a2b3c4d5e6f7g8h9"
      }
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
      }
    ))
  ).eks.main,
  {
    vpc_config = {
      control_plane_subnets = dependency.vpc.outputs.public_subnet_names_to_attributes

      node_groups_subnets = dependency.vpc.outputs.private_subnet_names_to_attributes

      nat_gateway = {
        enabled   = true
        subnet_id = dependency.vpc.outputs.public_subnet_names_to_attributes["network-appliance-a"].id
      }

      vpc_id                   = dependency.vpc.outputs.vpc_id
      endpoint_public_access   = true
    }

    tags = local.tags
  }
)

