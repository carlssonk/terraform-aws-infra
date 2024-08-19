variable "backend_bucket_name" {}
variable "backend_table_name" {}
variable "organization" {}
variable "environment" {}
variable "repository" {}

terraform {
  backend "s3" {}
}

locals {
  domain = "token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://${local.domain}"
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
          "${local.domain}:aud": "sts.amazonaws.com"
        }
        StringLike = {
          "${local.domain}.com:sub": "repo:${var.organization}/${var.repository}:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "terraform_base_policy" {
  name = "terraform-base-policy"
  description = "Policy for initial setup and self-update capabilities"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        // Required for backend management
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource: [
          "arn:aws:s3:::${var.organization}-${var.backend_bucket_name}-${var.environment}",
          "arn:aws:s3:::${var.organization}-${var.backend_bucket_name}-${var.environment}/*"
        ]
      },
      {
        // Required for backend management
        Effect: "Allow",
        Action: [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource: "arn:aws:dynamodb:*:*:table/${var.organization}-${var.backend_table_name}-${var.environment}"
      },
      {
        // Required for communicating with OpenID Connect Provider
        Effect: "Allow",
        Action: [
          "iam:GetOpenIDConnectProvider",
        ],
        Resource: "arn:aws:iam::*:oidc-provider/${local.domain}"
      },
      {
        // Enables policy to get itself
        Effect: "Allow",
        Action: [
          "iam:GetPolicy",
        ],
        Resource: self.arn
      },
      {
        // Enables role to add policies to itself
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = aws_iam_role.terraform_execution_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policy" {
  policy_arn = aws_iam_policy.terraform_base_policy.arn
  role = aws_iam_role.terraform_execution_role.name
}