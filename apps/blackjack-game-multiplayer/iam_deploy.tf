locals {
  github_repo_name = "carlssonk/Blackjack-Game-Multiplayer"
  oidc_domain      = "token.actions.githubusercontent.com"
}

resource "aws_iam_role" "this" {
  count = var.workflow_step == "iam" ? 1 : 0
  name  = "${local.app_name}-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${module.globals.var.AWS_ACCOUNT_ID}:oidc-provider/${local.oidc_domain}"
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
  count = var.workflow_step == "iam" ? 1 : 0
  name  = "${local.app_name}-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          "arn:aws:ecr:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:repository/${module.ecs_service.repo_name}",
          "arn:aws:ecr:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:repository/${module.ecs_service.repo_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeCluster",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:UpdateService"
        ]
        Resource = [
          "arn:aws:ecs:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:service/MainCluster/${module.ecs_service.service_name}",
          "arn:aws:ecs:${module.globals.var.REGION}:${module.globals.var.AWS_ACCOUNT_ID}:service/MainCluster/${module.ecs_service.service_name}/*"
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
  count      = var.workflow_step == "iam" ? 1 : 0
  policy_arn = aws_iam_policy.this[0].arn
  role       = aws_iam_role.this[0].name
}
