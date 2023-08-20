resource "aws_s3_bucket" "source" {
  bucket        = var.source_bucket_name
  provider      = aws.Source
  force_destroy = var.force_destroy

}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.Source
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.source.id

  rule {
    status    = "Enabled"
    priority  = 0
    id        = "destination"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_acl" "source" {
  provider      = aws.Source
  bucket = aws_s3_bucket.source.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source" {
  provider      = aws.Source
  bucket = aws_s3_bucket.source.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "source" {
  provider      = aws.Source
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = var.versioned
  }
}

resource "aws_s3_bucket_public_access_block" "source" {
  provider      = aws.Source
  bucket = aws_s3_bucket.source.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}
