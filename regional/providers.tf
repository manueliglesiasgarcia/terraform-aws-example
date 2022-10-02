provider "aws" {
  region  = module.dev_envs.aws_accounts[terraform.workspace]["region"]
  profile = "default"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

