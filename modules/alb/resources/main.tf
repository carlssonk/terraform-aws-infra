resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true
}

resource "aws_acm_certificate" "this" {
  for_each                  = toset(var.root_domain_names)
  domain_name               = each.value
  validation_method         = "DNS"
  subject_alternative_names = ["*.${each.value}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "acm_certificate-${each.value}"
  }
}

module "cloudflare_records" {
  for_each    = toset(var.root_domain_names)
  source      = "../../cloudflare-record/default"
  root_domain = each.value
  dns_records = [for dvo in aws_acm_certificate.this[each.value].domain_validation_options : {
    name    = dvo.resource_record_name
    value   = dvo.resource_record_value
    type    = dvo.resource_record_type
    ttl     = 60
    proxied = false
  }]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Please use a valid hostname"
      status_code  = "404"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "lb_listener"
  }
}

resource "aws_lb_listener_certificate" "this" {
  for_each        = toset(var.root_domain_names)
  listener_arn    = aws_lb_listener.front_end.arn
  certificate_arn = aws_acm_certificate[each.value].arn
}
