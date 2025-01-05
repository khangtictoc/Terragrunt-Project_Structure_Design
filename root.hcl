generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "terragrunt-state-backend"
    key            = "${path_relative_to_include()}/terragrunt.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terragrunt-state-lock"
  }
}
EOF
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}

locals {
  root_module_path = find_in_parent_folders("root.hcl")
}

terraform {
  before_hook "create_backend_resources" {
    commands = ["init", "apply"]
    execute  = ["bash", "${substr(local.root_module_path, 0, length(local.root_module_path) - 8)}/hook_script/create-backend-resources.sh"]
  }
}