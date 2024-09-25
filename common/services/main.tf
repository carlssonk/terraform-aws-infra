module "globals" {
  source = "../../globals"
}

locals {
  main_alb_access_logs_bucket_name = "${module.globals.var.organization}-main-alb-logs"
  elb_account_ids = {
    eu-north-1 = "897822967062" // ID found in AWS docs https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  }
}

module "service_discovery_namespace" {
  count          = var.reverse_proxy_type == "nginx" ? 1 : 0
  source         = "../../modules/service-discovery/default"
  namespace_name = module.globals.var.organization
}

locals {
  www_domains = {
    for domain, value in var.root_domains :
    "www.${domain}" => value
  }
  base_domains = concat(values(var.root_domains), values(local.www_domains))

  certbot_domains = join(" -d ", local.base_domains)
}

data "template_file" "nginx_config" {
  count    = var.reverse_proxy_type == "nginx" ? 1 : 0
  template = file("${path.module}/nginx_template.conf")
  vars = {
    services_map = jsonencode({
      "flagracer.carlssonk.com" = "carlssonk/flagracer",
      "blackjack.carlssonk.com" = "carlssonk/blackjack",
    })
    domain_names = local.base_domains
  }
}

module "ec2_instance_nginx" {
  count             = var.reverse_proxy_type == "nginx" ? 1 : 0
  name              = "nginx-reverse-proxy"
  source            = "../../modules/ec2-instance/default"
  ami               = "ami-0129bfde49ddb0ed6"
  instance_type     = "t3.micro"
  subnet_id         = var.networking_outputs.main_vpc_public_subnet_ids[0]
  security_group_id = var.security_outputs.security_group_alb_id # Should have the same security group rules as alb

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx certbot python3-certbot-nginx

    # Install NGINX configuration
    cat <<EOT > /etc/nginx/nginx.conf
    ${data.template_file.nginx_config[0].rendered}
    EOT

    # Obtain SSL certificate (replace example.com with your domain)
    certbot --nginx -d ${local.certbot_domains} --non-interactive --agree-tos -m oliver@carlssonk.com

    # Ensure Certbot auto-renewal is enabled
    systemctl enable certbot.timer
    systemctl start certbot.timer

    # Restart NGINX to apply changes
    systemctl restart nginx
    EOF

  tags = {
    Name = "Nginx Reverse Proxy"
  }
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
