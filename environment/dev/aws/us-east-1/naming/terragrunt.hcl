include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}



# Use self-developed modules
# terraform {
#     source = "../../../../../modules/azure/naming"
# }

# ┌──────────────────────────────────────────────────────────────────┐ 
# │                                                                  │
# │    Self-developed  Module - Terraform HashiCorp Registry         │ 
# │                                                                  │
# └──────────────────────────────────────────────────────────────────┘

# Use self-developed modules
terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/azure/naming.git"
}

locals {
  env = include.root.locals.env
}

inputs = {
  project = {
    name = "testproject"
    aws = {
      eks_cluster = {
        target_name = "general"
        index       = 0
      }
      vpc = {
        target_name = "general"
        index       = 0
      }
    }
  }
  env = local.env
}

