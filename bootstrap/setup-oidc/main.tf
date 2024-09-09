terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

locals {
  oidc_domain           = "token.actions.githubusercontent.com"
  terraform_base_policy = "terraform-base-policy"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://${local.oidc_domain}"
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
          "${local.oidc_domain}:aud" : "sts.amazonaws.com"
        }
        StringLike = {
          "${local.oidc_domain}:sub" : "repo:${var.organization}/${var.repository}:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "terraform_base_policy" {
  name        = local.terraform_base_policy
  description = "Policy for initial setup and self-update capabilities"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        // Required for backend management
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource : [
          "arn:aws:s3:::${var.organization}-terraform-state-bucket-${terraform.workspace}",
          "arn:aws:s3:::${var.organization}-terraform-state-bucket-${terraform.workspace}/*"
        ]
      },
      {
        // Required for backend management
        Effect : "Allow",
        Action : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource : "arn:aws:dynamodb:*:*:table/${var.organization}-terraform-lock-table-${terraform.workspace}"
      },
      {
        // Required for communicating with OpenID Connect Provider
        Effect : "Allow",
        Action : [
          "iam:GetOpenIDConnectProvider",
        ],
        Resource : "arn:aws:iam::*:oidc-provider/${local.oidc_domain}"
      },
      {
        // Enables policy to read itself
        Effect : "Allow",
        Action : [
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions"
        ],
        Resource : "arn:aws:iam::*:policy/${local.terraform_base_policy}"
      },
      {
        // Enables policy to create and manage terraform-*-policy + *-deploy-policy
        Effect : "Allow",
        Action : [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicyVersions",
          "iam:GetPolicyVersion",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion"
        ],
        Resources : [
          "arn:aws:iam::*:policy/terraform-*-policy",
          "arn:aws:iam::*:role/*-deploy-policy"
        ]
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
      },
      {
        // Used for creating iam_deploy roles
        Effect : "Allow",
        Action : [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies"
        ],
        Resource : "arn:aws:iam::*:role/*-deploy-role"
      },
      {
        // Used when fetching a policy
        Effect = "Allow"
        Action = [
          "iam:ListPolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_policy" {
  policy_arn = aws_iam_policy.terraform_base_policy.arn
  role       = aws_iam_role.terraform_execution_role.name
}
