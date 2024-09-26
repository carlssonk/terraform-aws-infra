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

locals {
  main_alb_access_logs_bucket_name = "${module.globals.var.organization}-main-alb-logs"
  elb_account_ids = {
    eu-north-1 = "897822967062" // ID found in AWS docs https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  }

  AmazonLinux2023AMI = {
    eu-north-1 = "ami-0129bfde49ddb0ed6" // ami ID found in AWS console when creating a ec2 instance
  }

  wildcard_root_domains = {
    for domain, value in var.root_domains :
    domain => "*.${value}"
  }

  certbot_domains = join(" -d ", concat(values(var.root_domains), values(local.wildcard_root_domains)))
}

module "service_discovery_namespace" {
  count          = var.reverse_proxy_type == "nginx" ? 1 : 0
  source         = "../../modules/service-discovery/default"
  namespace_name = module.globals.var.organization
}

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
      #!/bin/bash

      sudo yum update -y
      sudo yum install -y nginx

      # Create nginx config
      sudo tee /etc/nginx/nginx.conf <<'EOF'
      events {
          worker_connections 1024;
      }

      http {
          map $http_host $upstream {
              hostnames;
              blackjack.carlssonk.com blackjack.carlssonk.local;
              flagracer.carlssonk.com flagracer.carlssonk.local;
          }

          server {
              listen 80;
              server_name blackjack.carlssonk.com flagracer.carlssonk.com;

              location / {
                  proxy_pass http://$upstream;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
              }
          }
      }
      EOF

      # Restart NGINX to apply changes
      sudo systemctl restart nginx
      EOT
  }
}

module "ec2_instance_nginx" {
  count             = var.reverse_proxy_type == "nginx" ? 1 : 0
  name              = "nginx-reverse-proxy"
  source            = "../../modules/ec2-instance/default"
  ami               = local.AmazonLinux2023AMI[module.globals.var.aws_region]
  instance_type     = "t3.micro"
  subnet_ids        = var.networking_outputs.main_vpc_public_subnet_ids
  security_group_id = var.security_outputs.security_group_nginx_id

  user_data = data.cloudinit_config.this.rendered
  # user_data = templatefile("${path.module}/nginx_reverse_proxy.tpl", {
  #   services_map = {
  #     "flagracer.carlssonk.com" = "carlssonk/flagracer", # TODO
  #     "blackjack.carlssonk.com" = "carlssonk/blackjack", # TODO
  #   }
  #   root_domains    = var.root_domains
  #   certbot_domains = local.certbot_domains
  # })
  # user_data = templatefile("${path.module}/run_every_boot.tpl", {
  #   nginx_config = templatefile("${path.module}/nginx_reverse_proxy.tpl", {
  #     services_map = {
  #       "flagracer.carlssonk.com" = "carlssonk/flagracer", # TODO
  #       "blackjack.carlssonk.com" = "carlssonk/blackjack", # TODO
  #     }
  #     root_domains    = var.root_domains
  #     certbot_domains = local.certbot_domains
  #   })
  # })

  tags = {
    Name = "Nginx Reverse Proxy"
  }
}

module "ec2_instance_nginx_eip" {
  count       = var.reverse_proxy_type == "nginx" ? 1 : 0
  source      = "../../modules/elastic-ip/default"
  instance_id = module.ec2_instance_nginx[0].id
}

module "main_alb_access_logs_bucket" {
  count       = var.reverse_proxy_type == "alb" ? 1 : 0
  source      = "../../modules/s3/default"
  bucket_name = local.main_alb_access_logs_bucket_name
  custom_bucket_policy = {
    Effect = "Allow",
    Principal = {
      AWS = "arn:aws:iam::${local.elb_account_ids[module.globals.var.aws_region]}:root"
    },
    Action   = "s3:PutObject",
    Resource = "arn:aws:s3:::${local.main_alb_access_logs_bucket_name}/AWSLogs/${module.globals.var.aws_account_id}/*"
  }
  force_destroy = true
}

module "main_alb" {
  count                    = var.reverse_proxy_type == "alb" ? 1 : 0
  source                   = "../../modules/alb/default"
  name                     = "main"
  vpc_id                   = var.networking_outputs.main_vpc_id
  subnet_ids               = var.networking_outputs.main_vpc_public_subnet_ids
  security_group_id        = var.security_outputs.security_group_alb_id
  domains_for_certificates = values(var.root_domains)
  access_logs_bucket_name  = local.main_alb_access_logs_bucket_name
  access_logs_enabled      = false
}

module "main_ecs_cluster" {
  source       = "../../modules/ecs-cluster/default"
  cluster_name = "MainCluster"
}
