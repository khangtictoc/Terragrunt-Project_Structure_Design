# https://www.infyways.com/tools/text-box-generator/

locals {
  # Terragrunt Settings
  root_module_path = find_in_parent_folders("root.hcl")
  root_folder_path = "${substr(local.root_module_path, 0, length(local.root_module_path) - 9)}"
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  platform_vars    = read_terragrunt_config(find_in_parent_folders("platform.hcl"))
  arg_masks        = read_terragrunt_config(find_in_parent_folders("config-args.hcl")).locals.parameters

  # Project Settings
  account_name        = "personal"
  global_project_name = "testproject"
  env                 = local.environment_vars.locals.env
  region              = local.region_vars.locals.region
  platform            = local.platform_vars.locals.platform

  tags = {
    "Platform"    = local.platform
    "Environment" = local.env
    "Region"      = local.region
    "ManagedBy"   = "terraform"
    "ManagedBy2"  = "terragrunt"
  }

  cloud_provider = regex(".*/(aws|azure|hcp)/.*", path_relative_to_include())[0]

  # Profile Settings
  profile = (
    local.env == "dev" ? "${local.account_name}-dev" :
    local.env == "staging" ? "${local.account_name}-staging" :
    local.env == "prod" ? "${local.account_name}-prod" :
    "default"
  )

  backend_s3_bucket           = "terragrunt-state-backend-708617"
  terragrunt_output_s3_bucket = "terragrunt-output-708617"
}

# ┌──────────────────────────────────────┐
# │                                      │
# │        BACKEND CONFIGURATION         │
# │                                      │
# └──────────────────────────────────────┘
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "${local.backend_s3_bucket}"
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

generate "provider_config" {
  path      = "provider.tf"
  if_exists = "skip"
  contents  = <<-EOF
provider "aws" {
  region  = "${local.region}"
  # profile = "default"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}
EOF
}

# ┌──────────────────────────────────┐
# │                                  │
# │   PROVIDER VERSION CONSTRAINT    │
# │                                  │
# └──────────────────────────────────┘

generate "terraform_version_constraint" {
  path      = "terraform.tf"
  if_exists = "skip"
  contents  = <<-EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.42.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}
EOF
}

# ┌──────────────────┐
# │                  │
# │   HOOK SET UP    │
# │                  │
# └──────────────────┘

terraform {
  before_hook "before_hook2" {
    commands     = ["apply", "plan"]
    execute      = ["mkdir", "-p", "$HOME/.kube"]
  }

  before_hook "before_hook3" {
    commands     = ["apply", "plan"]
    execute      = ["bash", "${local.root_folder_path}/hook_script/pre-processing.sh"]
  }

  before_hook "before_hook4" {
    commands     = ["apply", "plan"]
    execute      = ["cat", "provider.tf"]
  }

  after_hook "post_processing" {
    commands = ["apply"]
    execute  = ["bash", "${local.root_folder_path}/hook_script/post-processing.sh", "${local.root_folder_path}/output", local.terragrunt_output_s3_bucket]
  }
}