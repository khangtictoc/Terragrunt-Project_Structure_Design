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
  source = "tfr:///terraform-aws-modules/vpc/aws?version=6.0.1"
}

locals {
  name     = "testproject"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  env      = include.root.locals.env
  tags     = include.root.locals.tags
}


inputs = {
  name = "testproject-${local.env}-vpc"
  cidr = local.vpc_cidr
  azs  = local.azs

  private_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  private_subnet_names = ["private-subnet-one", "private-subnet-two"]
  public_subnets_names = ["public-subnet-one", "public-subnet-two"]

  enable_nat_gateway               = true
  create_private_nat_gateway_route = true
  single_nat_gateway               = true

  tags = local.tags
}

