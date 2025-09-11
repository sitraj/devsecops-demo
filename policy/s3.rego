package s3

# Check for public S3 bucket ACLs (new resource structure)
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_acl"
    resource.change.after.acl == "public-read"
    msg := sprintf("❌ S3 bucket ACL %s is public", [resource.address])
}

# Check for public S3 bucket ACLs (legacy structure)
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl == "public-read"
    msg := sprintf("❌ S3 bucket %s is public", [resource.address])
}