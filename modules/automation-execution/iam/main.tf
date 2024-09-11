
# data "aws_iam_policy_document" "this" {
#   statement {
#     actions = concat(
#       [
#         "ec2:CreateVpc",
#         "ec2:DeleteVpc",
#         "ec2:CreateVpcEndpoint",
#         "ec2:DeleteVpcEndpoints",
#         "ec2:ModifyVpcAttribute",
#         "ec2:CreateTags",
#         "ec2:DeleteTags",
#         "ec2:CreateSubnet",
#         "ec2:DeleteSubnet",
#         "ec2:ModifySubnetAttribute",
#         "ec2:CreateRouteTable",
#         "ec2:DeleteRouteTable",
#         "ec2:CreateRoute",
#         "ec2:DeleteRoute",
#         "ec2:AssociateRouteTable",
#         "ec2:DisassociateRouteTable",
#         "ec2:CreateInternetGateway",
#         "ec2:DeleteInternetGateway",
#         "ec2:AttachInternetGateway",
#         "ec2:DetachInternetGateway",
#         "ec2:CreateSecurityGroup",
#         "ec2:DeleteSecurityGroup",
#         "ec2:AuthorizeSecurityGroupIngress",
#         "ec2:AuthorizeSecurityGroupEgress",
#         "ec2:RevokeSecurityGroupIngress",
#         "ec2:RevokeSecurityGroupEgress",
#         "ec2:ModifySecurityGroupRules",
#         "ec2:Describe*"
#       ]
#     )
#     resources = ["*"]
#     effect    = "Allow"
#   }
# }

# output "policy_document" {
#   value = data.aws_iam_policy_document.this.json
# }
