terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
    }
  }
}

module "globals" {
  source = "../../globals"
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  main_alb_access_logs_bucket_name = "${module.globals.var.organization}-main-alb-logs"
  elb_account_ids = {
    eu-north-1 = "897822967062" // ID found in AWS docs https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  }

  AmazonLinux2023AMI = {
    eu-north-1 = "ami-0d916634f7eb5727f" // ami ID found in AWS console when creating a ec2 instance (ARM64 based)
  }

  nginx_server_name = join(" ", [
    for _, config in var.fargate_services :
    "${config.subdomain}.${config.root_domain}"
  ])

  namespace_name = module.globals.var.organization

  // Expects that the ecs service discovery names are the same as their subdomains
  services_map = {
    for _, config in var.fargate_services :
    "${config.subdomain}.${config.root_domain}" => "${config.subdomain}.${local.namespace_name}:${config.container_port}"
  }
}

module "service_discovery_namespace" {
  count          = var.reverse_proxy_type == "nginx" ? 1 : 0
  source         = "../../modules/service-discovery"
  namespace_name = local.namespace_name
  vpc_id         = var.networking_outputs.main_vpc_id
}

data "cloudinit_config" "this" {
  count         = var.workflow_step == "resources" && var.reverse_proxy_type == "nginx" ? 1 : 0
  gzip          = false
  base64_encode = false

  part { // This will make sure that the config runs every time instance boots
    content_type = "text/cloud-config"
    content      = <<-EOF
    #cloud-config
    cloud_final_modules:
      - [scripts-user, always]
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/nginx_proxy.tpl", {
      services_map    = local.services_map
      dns_resolver_ip = var.networking_outputs.main_vpc_dns_resolver_ip
      server_name     = local.nginx_server_name
    })
  }
}

module "ec2_instance_nginx" {
  count             = var.reverse_proxy_type == "nginx" ? 1 : 0
  name              = "nginx-reverse-proxy"
  source            = "../../modules/ec2-instance"
  ami               = local.AmazonLinux2023AMI[data.aws_region.current.name]
  instance_type     = var.ec2_instances.nginx_proxy_settings.instance_type
  subnet_ids        = var.networking_outputs.main_vpc_public_subnet_ids
  security_group_id = var.security_outputs.security_group_nginx_id

  use_spot           = var.ec2_instances.nginx_proxy_settings.use_spot
  spot_max_price     = var.ec2_instances.nginx_proxy_settings.spot_max_price
  spot_instance_type = var.ec2_instances.nginx_proxy_settings.spot_instance_type

  user_data = try(data.cloudinit_config.this[0].rendered, "")

  tags = {
    Name = "Nginx Reverse Proxy"
  }
}

module "ec2_instance_nginx_eip" {
  count       = var.reverse_proxy_type == "nginx" ? 1 : 0
  source      = "../../modules/elastic-ip"
  instance_id = module.ec2_instance_nginx[0].id
}

module "main_alb_access_logs_bucket" {
  count       = var.reverse_proxy_type == "alb" ? 1 : 0
  source      = "../../modules/s3"
  bucket_name = local.main_alb_access_logs_bucket_name
  custom_bucket_policy = {
    Effect = "Allow",
    Principal = {
      AWS = "arn:aws:iam::${local.elb_account_ids[data.aws_region.current.name]}:root"
    },
    Action   = "s3:PutObject",
    Resource = "arn:aws:s3:::${local.main_alb_access_logs_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
  }
  force_destroy = true
}

module "main_alb" {
  count                    = var.reverse_proxy_type == "alb" ? 1 : 0
  source                   = "../../modules/alb"
  name                     = "main"
  vpc_id                   = var.networking_outputs.main_vpc_id
  subnet_ids               = var.networking_outputs.main_vpc_public_subnet_ids
  security_group_id        = var.security_outputs.security_group_alb_id
  domains_for_certificates = values(var.root_domains)
  access_logs_bucket_name  = local.main_alb_access_logs_bucket_name
  access_logs_enabled      = false
}

module "main_ecs_cluster" {
  source       = "../../modules/ecs-cluster"
  cluster_name = "MainCluster"
}
