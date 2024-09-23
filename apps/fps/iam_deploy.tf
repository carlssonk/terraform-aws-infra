module "globals" {
  source = "../../globals"
}

locals {
  oidc_domain = "token.actions.githubusercontent.com"
}

resource "aws_iam_role" "this" {
  count = var.workflow_step == "resources" ? 1 : 0
  name  = "${local.app_name}-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${module.globals.var.aws_account_id}:oidc-provider/${local.oidc_domain}"
      }
      Condition = {
        StringEquals = {
          "${local.oidc_domain}:aud" : "sts.amazonaws.com"
        }
        StringLike = {
          "${local.oidc_domain}:sub" : "repo:${local.github_repo_name}:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "this" {
  count = var.workflow_step == "resources" ? 1 : 0
  name  = "${local.app_name}-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${local.domain_name}",
          "arn:aws:s3:::${local.domain_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.workflow_step == "resources" ? 1 : 0
  policy_arn = aws_iam_policy.this[0].arn
  role       = aws_iam_role.this[0].name
}
