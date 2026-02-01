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
  source = "git::https://gitlab.com/terraform-modules7893436/kubernetes-deploy/argocd.git?ref=main"
}

dependency "k8s_cluster" {
  config_path = "../../../../${local.platform}/${local.region}/${local.cluster_type}"
  mock_outputs = {
    name = "test"
    service_account_role_arn = "arn:aws:iam::123456789012:role/YourALBControllerRole"
    vpc_id = "vpc-0abcd1234efgh5678"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "hcp_vault_cluster" {
  config_path = "../../../../hcp/${local.region}/vault-dedicated-cluster"
  mock_outputs = {
    public_endpoint = "https://testproject-dev-public-vault-6ca71e7f.86ddef82.z1.hashicorp.cloud:8200"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "hcp_vault_components" {
  config_path  = "../../../../hcp/${local.region}/vault-components"
  skip_outputs = true
}

locals {
  env          = include.root.locals.env
  region       = include.root.locals.region
  platform     = include.root.locals.platform
  cluster_type = lookup(include.mapping_conventions.locals.cluster_type, local.platform, "")
  arg_masks    = include.root.locals.arg_masks
}

inputs = yamldecode(
  templatefile("../config.yaml", merge(
    local.arg_masks,
    {
      region                    = local.region
      platform                  = local.platform
      k8s_cluster_name          = dependency.k8s_cluster.outputs.name
      hcp_vault_public_endpoint = dependency.hcp_vault_cluster.outputs.public_endpoint
      service_account_role_arn  = dependency.k8s_cluster.outputs.service_account_role_arn
      vpc_id                    = dependency.k8s_cluster.outputs.vpc_id
    }
  ))
).deployment_list.main


