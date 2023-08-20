terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.4.3"
    }
  }

  required_version = ">= 0.15"
}
