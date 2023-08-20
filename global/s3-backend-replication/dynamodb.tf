resource "aws_dynamodb_table" "dynamodb_table" {
  name             = "dev-terraform-lock-backend-replication"
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "LockID"
    type = "S"
  }

  replica {
    region_name = "us-west-2"
  }
}