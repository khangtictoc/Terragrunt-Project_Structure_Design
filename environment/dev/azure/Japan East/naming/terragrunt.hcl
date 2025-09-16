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

inputs = {
  project = {
    name = "testproject"
    aks_cluster = {
      target_name = "labs"
      index = 0
    }
    resource_group = {
      target_name = "general"
      index = 0
    }
    key_vault = {
      target_name = "general"
      index = 0
    }
    storage_account = {
      target_name = "general"
      index = 0
    }
    vnet = {
      target_name = "general"
      index = 0
    }
  }
}

