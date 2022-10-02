terraform {
  backend "s3" {
    bucket  = "dev-terraform-backend-state-us-east-1"
    key     = "us-east-1.tfstate"
    region  = "us-east-1"
    profile = "default"
    encrypt = true
    dynamodb_table = "dev-terraform-lock-backend-replication"
  }
}
