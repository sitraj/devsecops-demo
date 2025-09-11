package ec2

# Deny security groups with overly permissive rules
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    rule := resource.change.after.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port == 22
    rule.to_port == 22
    msg := sprintf("❌ Security group %s allows SSH (port 22) from anywhere (0.0.0.0/0)", [resource.address])
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    rule := resource.change.after.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port == 3389
    rule.to_port == 3389
    msg := sprintf("❌ Security group %s allows RDP (port 3389) from anywhere (0.0.0.0/0)", [resource.address])
}

# Deny EC2 instances without encryption
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    ebs_device := resource.change.after.ebs_block_device[_]
    not ebs_device.encrypted
    msg := sprintf("❌ EC2 instance %s has unencrypted EBS volumes", [resource.address])
}
