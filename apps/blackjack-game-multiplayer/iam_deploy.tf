locals {
  oidc_domain = "token.actions.githubusercontent.com"
}

module "globals" {
  source = "../../globals"
}

resource "aws_iam_role" "this" {
  name = "${local.app_name}-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_domain
      }
      Condition = {
        StringEquals = {
          "${local.oidc_domain}:aud" : "sts.amazonaws.com"
        }
        StringLike = {
          "${local.oidc_domain}:sub" : "repo:${local.repo_name}:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "this" {
  name = "${local.app_name}-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resources = [
          "arn:aws:ecr:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:repository/${module.ecs_service.repo_name}",
          "arn:aws:ecr:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:repository/${module.ecs_service.repo_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeCluster",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resources = [
          "arn:aws:ecs:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:service/SimpleCluster/${module.ecs_service.service_name}",
          "arn:aws:ecs:${module.globals.var.region}:${module.globals.var.AWS_ACCOUNT_ID}:service/SimpleCluster/${module.ecs_service.service_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" : "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
