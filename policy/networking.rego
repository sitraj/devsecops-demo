package networking

# Deny VPCs without flow logs
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_vpc"
    not resource.change.after.enable_dns_hostnames
    msg := sprintf("❌ VPC %s does not have DNS hostnames enabled", [resource.address])
}

# Deny subnets without proper tagging
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_subnet"
    not resource.change.after.tags
    msg := sprintf("❌ Subnet %s does not have any tags", [resource.address])
}

# Deny internet gateways without proper association
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_internet_gateway"
    not resource.change.after.vpc_id
    msg := sprintf("❌ Internet Gateway %s is not associated with a VPC", [resource.address])
}

# Deny load balancers without HTTPS listeners
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_lb_listener"
    resource.change.after.protocol == "HTTP"
    resource.change.after.port == 80
    msg := sprintf("❌ Load balancer listener %s uses HTTP instead of HTTPS", [resource.address])
}
