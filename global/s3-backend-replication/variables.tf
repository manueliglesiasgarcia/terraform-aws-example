variable "terraform_user_name" {
  type        = string
  default     = "default-local"
  description = "Something to sign the session with, does not have anything to do with IAM"
}

variable "source_bucket_name" {
  type        = string
  description = "Source Bucket Name"
}

variable "private" {

  description = "Allow public read access to bucket"
  default     = "private"
}

variable "force_destroy" {
  description = "Delete all objects in bucket on destroy"
  default     = false
}

variable "versioned" {
  type        = string
  description = "Version the bucket"
  default     = "Enabled"
}

variable "lifecycle_enabled" {
  description = "Is Lifecycle enabled?"
  default     = false
}

variable "iam_role_name" {
  type        = string
  description = "IAM Role name for replication"
}

variable "destination_bucket_name" {
  type        = string
  description = "Destination bucket name"
}

variable "iam_role_kms" {
  type        = string
  description = "IAM Role name for KMS"
}
