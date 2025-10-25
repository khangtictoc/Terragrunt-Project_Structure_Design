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

dependency "aks" {
  config_path = "../../../azure/Japan West/aks"
}

locals {
  name     = "testproject-${local.env}"
  env      = include.root.locals.env
  region   = include.root.locals.region

  arg_masks     = include.root.locals.arg_masks
}

inputs = merge(
  yamldecode(
    templatefile("../config.yaml", merge(
      local.arg_masks,
      {
        region = local.region
        aks__name = dependency.naming.outputs.aks_cluster_name
        aks__rg_name = dependency.naming.outputs.resource_group_name
        aks__kubeconfig_output_path   = local.kubeconfig_output_path
        aks__vnet_subnet_id = dependency.vnet.outputs.subnet_ids.workloads
        aks__ingress_appgw_id = dependency.aks_appgw.outputs.id
        aks__vnet_id = dependency.vnet.outputs.vnet_id
      }
    ))
  ).vault_dedicated_cluster_list.main,
  {
    tags = local.tags
  }
)