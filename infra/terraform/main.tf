provider "aws" { 
  region = "us-east-1" 
}
# Get current AWS account info 
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "devsecops-demo-bucket" {
  bucket = "devsecops-demo-bucket-${data.aws_caller_identity.current.account_id}" 
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "devsecops-demo-security" {
  bucket = aws_s3_bucket.devsecops-demo-bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}