# https://www.infyways.com/tools/text-box-generator/

locals {
  ### Terragrunt Settings
  root_module_path = find_in_parent_folders("root.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  ### Project Settings
  project_name    = "testproject"
  env    = local.environment_vars.locals.env
  region = local.region_vars.locals.region

  # Account & Profile Settings
  profile = (
    local.env == "dev" ? "${local.project_name}-dev" :
    local.env == "staging" ? "${local.project_name}-staging" :
    local.env == "prod" ? "${local.project_name}-prod" :
    "default"
  )
}

# ┌──────────────────────────────────────┐
# │                                      │
# │        BACKEND CONFIGURATION         │
# │                                      │
# └──────────────────────────────────────┘
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


# ┌──────────────────────────────────────┐
# │                                      │
# │   PROVIDER & ACCOUNT CONFIGURATION   │
# │                                      │
# └──────────────────────────────────────┘
generate "provider-us-east-1-dev" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"
}
EOF
}

# ┌──────────────────┐
# │                  │
# │   HOOK SET UP    │
# │                  │
# └──────────────────┘

terraform {
  before_hook "create_backend_resources" {
    commands = ["init", "plan", "apply"]
    execute  = ["bash", "${substr(local.root_module_path, 0, length(local.root_module_path) - 8)}/hook_script/create-backend-resources.sh"]
  }
}