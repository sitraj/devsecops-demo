package logging

# Deny resources without CloudTrail logging
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudtrail"
    not resource.change.after.enable_logging
    msg := sprintf("❌ CloudTrail %s does not have logging enabled", [resource.address])
}

# Deny CloudWatch log groups without retention
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudwatch_log_group"
    not resource.change.after.retention_in_days
    msg := sprintf("❌ CloudWatch log group %s does not have retention period set", [resource.address])
}

# S3 bucket logging requirement removed - not mandatory for this demo

# Deny VPCs without flow logs
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_flow_log"
    not resource.change.after.log_destination
    msg := sprintf("❌ VPC Flow Log %s does not have a log destination configured", [resource.address])
}
