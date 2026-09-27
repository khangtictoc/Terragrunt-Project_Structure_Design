# --- HEADERS --------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# --- IMPORT MODULES --------------------

## [1] -> Use self-developed modules

# terraform {
#     source = "../../../../../modules/aws/vpc"
# }

## [2] -> Use remote modules (Community, Gitlab, Github, etc.)

terraform {
  source = "git::https://gitlab.com/terraform-modules7893436/general/naming.git?ref=main"
}

# --- INPUT VALUES --------------------

locals {
  env     = include.root.locals.env
  config  = yamldecode(file("../config.yaml"))
  project = local.config.project
}

inputs = {
  project = local.project
  env     = local.env
}

