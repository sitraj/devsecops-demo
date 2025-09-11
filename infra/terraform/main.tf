provider "aws" {
  region = "us-east-1"
}

# Get current AWS account info
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "example" {
  bucket = "devsecops-demo-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
