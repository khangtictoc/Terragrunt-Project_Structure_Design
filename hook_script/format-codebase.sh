#! /bin/bash

terragrunt hclfmt --terragrunt-working-dir .
terraform fmt -recursive