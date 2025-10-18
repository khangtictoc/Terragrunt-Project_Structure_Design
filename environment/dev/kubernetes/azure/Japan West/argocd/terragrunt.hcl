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
      cluster_ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUU2RENDQXRDZ0F3SUJBZ0lRSWNVMzNKelV4OXVCZCtmaW4xVlhqREFOQmdrcWhraUc5dzBCQVFzRkFEQU4KTVFzd0NRWURWUVFERXdKallUQWdGdzB5TlRFd01UZ3dNekUxTkRGYUdBOHlNRFUxTVRBeE9EQXpNalUwTVZvdwpEVEVMTUFrR0ExVUVBeE1DWTJFd2dnSWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUNEd0F3Z2dJS0FvSUNBUURTCjdmV1RsZllYWmdYdThLc202TWJVWnJ2U3M0eGFGT3hvcDFkQlVsNVlLZDBMNVNsdzFFdTBpcVZNZmNUVm1BTXEKOVpTTm12aFlRczl5bVFzR2hDTFo5ZHEwRDNQTHF5c1l0OXAwaDVjZnhRc1NjWnIwK2RZSDlnamtvcXlHRDB1TwpSdkpJUjNMT01CR0FiTC8rVk9YL0NVV2p3amxETWd3U3c4SWY1ait2TE51UUFodG9KUm83OHpHODZyVVRFSWl0CnoxMzYzTFpTMmlhcHh4VUdwbkloY3p2Qno5T29KNUZ3QU5FalNUTjZKOEUxQ3hxeW1zNEtjODEvbEpsWlhOOEoKbmJtRWFnNVZncndEMlRUTzZkb2pvWnUrZ3hsVVdQVGpHd3lUaXo1RHRzZ3RSR0tGSXJzZDFFR3B1SmdUQ0FtdgpQbzhwcHlyUHlJVUdsWlhwcTZmN2txdzFod1FZaWgxZzZtaTVmV0NqZGljUUVORG5qUjBiaXNQYTMzR1lIUXZDCnJuSnA3V09qUzd1U0Z6dks0ZTRiSWtQMno4YzJZQVh2eDIzdzQ3YmFiK3dkYTNyZWZsZ056MUR0Rkp2aHRuRkcKbVd2UFZjUVBkajFBNm15WSttK2tDVGdxQUxuZUpKaUlQOXFhOEszZjl0Z0oreTJkSUFpbVpDS3owWkxUWDdTVAo3TWtFTEhudlBxWExBZ2lqamttOHFZKzEyVnQrOXgvU2M2U3VvKzBwejBOV0k5S2xWYWllTTlOcHg5a0dXS3RiCnJ5bGpCNDBIRnJUZG1obTdwL3dFZUpoNFM0THRhT0x5NTlVL0FVSVIvMVZsVFhjQTM1dU1KR1hpb3g1OXlSRmoKUmtieGQzRDMxWmtmSnltQ2lqRGVFOFNET3lGNmk4QkNvWjM2OXF2TzJRSURBUUFCbzBJd1FEQU9CZ05WSFE4QgpBZjhFQkFNQ0FxUXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QWRCZ05WSFE0RUZnUVVJbk94M1JwY1hQS3BUK0FyClhzOUtRUGQvYXpRd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dJQkFKaDJEMjlSWnRTUUUrVU9YR3ZWc201SnZ3ZjQKVlRkdWxhS1p5VnJ0VDlKS1NXZkFxWTRsY0tKbStLVENBUUp4emlCYzlOZkdQRTdnODNhRDJDNjJQS1pCSlRJdApJeHl6S3pKYWhBNWN5a0NGS1lRQ3U4eDVNT1hJYVRlVXl5ZjhXa291QXlOeEgzakovRUY0cEJFRnBLYUxlQklVCkRCclpkNUxCaUVnSldGMDF2VlBZZHZsVmtWcjV6Sld0TmtFOWMzZ2RrVzRKWGtmUkpvUUp0Vk9OUFhtVndjUjIKVVhRY3lqZEFHdUlGaXM4YXJhWlhaRWZWRDhIK0RxKyt3d3FvMjMyVXVwYnpyQlNvSHlaVnJaZFlzMTB0UGloQwptUlR4dnpGaTg0Q0FXendOVmVhQ3drZ0w4TEEzYzFvY3FVVXhGOXlMUFVFekJnc0d5Zm1ZVXFEenMxd0pIOCt6Cm43bjRGK1Jjd0JORlJqb2c2ZlRLM3dyTHd1TGk5a0J4NWw3ZDZZYUFaaW40SFZsQTR0WGdDelhUYzRVNzhscFEKRVphYmtna1UrY2wvejJYb2N6QjY1bTRUeGtwdHpHcG9XWjV6OVNndGxCcXVic2lXMjdSN2pwQmZ0cEdkRGd1SgpRUWZaZHJUSHZQSUk2c0QxQWxneVpUcXFKUXZWcGE2RTlqSlV0MlkvZ2RnWjJ5Z0M2dVBZdWJIR1JiMzExUzRjCnZ4ZEtVMSsvUEFRRHVpY1BYd1JIc2pTcDVGcml5TDNmOU50TDhTOW9aMmFUckhYOHJhcGVLZVFoSXhubEY2NWUKaGJMbjZpVHFRdFZjMEk4UVFnZXNHT05BbGNyNkY4WHFWelhnaklHTFZqUEw3VWdSS2E2dEtUdlhXTHM3UTFDdQpZUmlxL0Q3TS9zMTJJNmJhCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
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
    ]

    value_file_path = [
        {
            override = true
            path ="argocd-values/nginx/values.yaml"
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

