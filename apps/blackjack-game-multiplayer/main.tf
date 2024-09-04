variable "workflow_step" {}
variable "aws_account_id" {}

variable "subnet_ids" {}
variable "cluster_id" {}
variable "security_group_id" {}

locals {
  app_name    = "blackjack" // also subdomain
  root_domain = "carlssonk.com"
}

module "subdomain_bucket" {
  workflow_step = var.workflow_step
  source        = "../../modules/s3"
  bucket_name   = "${local.app_name}.${local.root_domain}"
  website_config = {
    is_website = true
  }
  bucket_access_and_policy = "cloudflare"
}

module "cloudflare" {
  workflow_step = var.workflow_step
  source        = "../../modules/cloudflare"
  root_domain   = local.root_domain
  dns_records = [{
    name  = local.app_name,
    value = module.subdomain_bucket.website_endpoint
  }]
}

module "ecs_task_definition" {
  workflow_step  = var.workflow_step
  aws_account_id = var.aws_account_id
  source         = "../../modules/ecs-task-definition"
  task_name      = "task-${local.app_name}"
  cpu            = 256
  memory         = 512
  container_definitions = jsonencode([{
    name  = "node"
    image = "node:14-alpine"
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
  }])
}

module "ecs_service" {
  workflow_step       = var.workflow_step
  source              = "../../modules/ecs-service"
  service_name        = "service-${local.app_name}"
  subnet_ids          = var.subnet_ids
  cluster_id          = var.cluster_id
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  security_group_id   = var.security_group_id
}

module "iam_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = local.app_name
  policy_documents = [module.subdomain_bucket.policy_document, module.ecs_task_definition.policy_document, module.ecs_service.policy_document]
}

output "policy_document" {
  value = module.iam_policy.policy_document
}
