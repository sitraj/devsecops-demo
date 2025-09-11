package encryption

# Deny S3 buckets without encryption
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    msg := sprintf("❌ S3 bucket %s does not have server-side encryption enabled", [resource.address])
}

# Deny RDS instances without encryption
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    not resource.change.after.storage_encrypted
    msg := sprintf("❌ RDS instance %s does not have encryption enabled", [resource.address])
}

# Deny EBS volumes without encryption
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    not resource.change.after.encrypted
    msg := sprintf("❌ EBS volume %s is not encrypted", [resource.address])
}

# Deny S3 buckets with weak encryption
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    encryption_config := resource.change.after.server_side_encryption_configuration
    rule := encryption_config.rule[_]
    sse_config := rule.apply_server_side_encryption_by_default[_]
    sse_config.sse_algorithm == "AES256"
    msg := sprintf("❌ S3 bucket %s uses weak AES256 encryption instead of KMS", [resource.address])
}
