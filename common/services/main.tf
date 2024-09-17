module "globals" {
  source = "../../globals"
}

locals {
  main_alb_access_logs_bucket_name = "${module.globals.var.ORGANIZATION}-main-alb-logs"
  elb_account_ids = {
    eu-north-1 = "897822967062" // ID found in AWS docs https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  }
}

module "main_alb_access_logs_bucket" {
  source      = "../../modules/s3/default"
  bucket_name = local.main_alb_access_logs_bucket_name
  custom_bucket_policy = {
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal : {
          "AWS" : "arn:aws:iam::${local.elb_account_ids[module.globals.var.AWS_REGION]}:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${local.main_alb_access_logs_bucket_name}/AWSLogs/${module.globals.var.AWS_ACCOUNT_ID}/*"
      }
    ]
  }
}

module "main_alb" {
  source                   = "../../modules/alb/default"
  name                     = "main"
  vpc_id                   = var.networking_outputs.main_vpc_id
  subnet_ids               = var.networking_outputs.main_vpc_public_subnet_ids
  security_group_id        = var.security_outputs.security_group_alb_id
  domains_for_certificates = ["carlssonk.com"]
  access_logs_bucket_name  = local.main_alb_access_logs_bucket_name
  access_logs_enabled      = true
}

module "main_ecs_cluster" {
  source       = "../../modules/ecs-cluster/default"
  cluster_name = "MainCluster"
}
