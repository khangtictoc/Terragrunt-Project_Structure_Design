# https://www.infyways.com/tools/text-box-generator/

locals {
  ### Terragrunt Settings
  root_module_path = find_in_parent_folders("root.hcl")
  root_folder_path = "${substr(local.root_module_path, 0, length(local.root_module_path) - 8)}"
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  ### Project Settings
  account_name        = "personal"
  global_project_name = "testproject"
  env                 = local.environment_vars.locals.env
  region              = local.region_vars.locals.region
  tags                = local.environment_vars.locals.tags
  
  cloud_provider = regex(".*/(aws|azure)/.*", path_relative_to_include())[0]

  # Account & Profile Settings
  profile = (
    local.env == "dev" ? "${local.account_name}-dev" :
    local.env == "staging" ? "${local.account_name}-staging" :  
    local.env == "prod" ? "${local.account_name}-prod" :
    "default"
  )

  provider_config = {
    aws = <<-EOF
provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"
  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}
EOF
    azure = <<-EOF
provider "azurerm" {
  resource_provider_registrations = "none"

  subscription_id = "ac90b42a-8ba9-48f5-9479-94dfd054e40d"
  tenant_id       = "4226c1de-24e6-4d6f-b050-b14a85140192"

  features {}
}
EOF
  }

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

generate "provider-config" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.cloud_provider == "aws" ? local.provider_config.aws : local.provider_config.azure
}

# ┌──────────────────────────────────┐
# │                                  │
# │   PROVIDER VERSION CONSTRAINT    │
# │                                  │
# └──────────────────────────────────┘

generate "provider-version" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
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
  }
}
EOF
}

# ┌──────────────────┐
# │                  │
# │   HOOK SET UP    │
# │                  │
# └──────────────────┘

# terraform {
#   before_hook "create_backend_resources" {
#     commands = ["init", "plan", "apply"]
#     execute  = ["bash", "${local.root_folder_path}/hook_script/create-backend-resources.sh"]
#   }
# }

# terraform {
#   before_hook "clean_up_cache_folder" {
#     commands = ["init", "plan", "apply"]
#     execute  = ["bash", "${local.root_folder_path}/hook_script/clean-cache.sh"]
#   }
# }