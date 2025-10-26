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
  source = "git::https://gitlab.com/terraform-modules7893436/kubernetes-deploy/argocd.git"
}

dependency "k8s_cluster" {
  config_path = "../../../../${local.platform}/${local.region}/${local.cluster_type}"
  mock_outputs = {
    host = "test"
    cluster_ca_certificate = "test"
    token = "test"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

dependency "hcp_vault_cluster" {
  config_path = "../../../../hcp/us-west-2/vault-dedicated-cluster"
  mock_outputs = {
    public_endpoint = "https://testproject-dev-public-vault-6ca71e7f.86ddef82.z1.hashicorp.cloud:8200"
  }
  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "output"]
}

locals {
  env      = include.root.locals.env
  region   = include.root.locals.region
  platform = include.root.locals.platform
  cluster_type = lookup(include.mapping_conventions.locals.cluster_type, local.platform, "")
}

inputs = {
  argocd_deploy = {

    kube_config = {
      host = dependency.k8s_cluster.outputs.host
      cluster_ca_certificate = dependency.k8s_cluster.outputs.cluster_ca_certificate
      token = dependency.k8s_cluster.outputs.token
    }

    install_kubectl = true
    install_argocd_cli = true
    install_argocd = true

    git_repo = {
      name = "argocd-apps"
      author = "khangtictoc"
      branch = "main"        
    }

    manifest_path_list = [
      "argocd_apps/nginx/applications.yaml",
      "argocd_apps/cert-manager/applications.yaml",
      "argocd_apps/hcp-vault/applications.yaml",
      "argocd_apps/jenkins/applications.yaml",
      "argocd_apps/vault-secrets-operator/applications.yaml",
      "argocd_apps/postgresql/applications.yaml",
      "argocd_apps/postgresql/vault-secrets.yaml",
      "argocd_apps/mongodb-sharded/vault-secrets.yaml",
      "argocd_apps/mongodb-sharded/vault-secrets.yaml",
    ]

    value_file_path = [
      {
        override = true
        path ="argocd_values/vault-secrets-operator/values.yaml"
        parameter_sets = [
          {
            key = ".defaultVaultConnection.address"
            value = dependency.hcp_vault_cluster.outputs.public_endpoint
          }
        ]
      }
    ]
  }
}

