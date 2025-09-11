package iam

# Deny overly permissive IAM policies
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_policy"
    policy_doc := json.unmarshal(resource.change.after.policy)
    statement := policy_doc.Statement[_]
    statement.Effect == "Allow"
    statement.Action == "*"
    statement.Resource == "*"
    msg := sprintf("❌ IAM policy %s is overly permissive (Action: *, Resource: *)", [resource.address])
}

# Deny IAM users with admin access
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_user_policy_attachment"
    resource.change.after.policy_arn == "arn:aws:iam::aws:policy/AdministratorAccess"
    msg := sprintf("❌ IAM user %s has AdministratorAccess policy attached", [resource.address])
}

# Deny IAM roles with admin access
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_role_policy_attachment"
    resource.change.after.policy_arn == "arn:aws:iam::aws:policy/AdministratorAccess"
    msg := sprintf("❌ IAM role %s has AdministratorAccess policy attached", [resource.address])
}
