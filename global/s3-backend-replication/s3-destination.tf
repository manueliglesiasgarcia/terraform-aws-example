resource "aws_s3_bucket" "destination" {
  bucket        = var.destination_bucket_name
  provider      = aws.Destination
  force_destroy = var.force_destroy

}

resource "aws_s3_bucket_acl" "destination" {
  provider = aws.Destination
  bucket = aws_s3_bucket.destination.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "destination" {
  provider = aws.Destination
  bucket = aws_s3_bucket.destination.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}


resource "aws_s3_bucket_versioning" "versioning_destination" {
  provider = aws.Destination
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = var.versioned
  }
}

resource "aws_s3_bucket_policy" "destination" {
  bucket   = aws_s3_bucket.destination.id
  provider = aws.Destination

  policy   = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:DeleteBucket"
      ],
      "Effect": "Deny",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.destination.id}",
      "Principal": {
        "AWS": ["*"]
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "destination" {
  bucket = aws_s3_bucket.destination.id
  provider      = aws.Destination

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}
