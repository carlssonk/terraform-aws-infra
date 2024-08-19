variable "organization" {}
variable "repository" {}

terraform {
  backend "s3" {}
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "terraform_execution_role" {
  name = "terraform-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub": "repo:${var.organization}/${var.repository}:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "terraform_bootstrap_policy" {
  name        = "terraform-bootstrap-policy"
  description = "Policy for initial setup and self-update capabilities"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = aws_iam_role.terraform_execution_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policy" {
  policy_arn = aws_iam_policy.terraform_custom_policy.arn
  role       = aws_iam_role.terraform_execution_role.name
}