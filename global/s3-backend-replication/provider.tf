provider "aws" {
  region = "us-east-1"
  profile = "default"
}

provider "aws" {
  alias   = "Source"
  region  = "us-east-1"
  profile = "default"
}


provider "aws" {
  alias   = "Destination"
  region  = "us-west-2"
  profile = "default"
}


data "aws_caller_identity" "current" {}
