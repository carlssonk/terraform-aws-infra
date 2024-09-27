resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  dynamic "access_logs" {
    for_each = var.access_logs_bucket_name != "" ? [1] : []
    content {
      bucket  = var.access_logs_bucket_name
      enabled = var.access_logs_enabled
    }
  }
}

module "acm_certificate" {
  source                    = "../../acm-certificate/default"
  for_each                  = toset(var.domains_for_certificates)
  domain_name               = each.value
  subject_alternative_names = ["*.${each.value}"]
}

# Terraform cannot determine how many records will be created (in the planning phase of apply) which will cause error so we hardcode the values
module "cloudflare" {
  for_each    = toset(var.domains_for_certificates)
  source      = "../../cloudflare-record"
  root_domain = each.value
  dns_records = {
    "carlssonk_0" = {
      name    = tolist(module.acm_certificate["carlssonk.com"].domain_validation_options)[0].resource_record_name
      value   = tolist(module.acm_certificate["carlssonk.com"].domain_validation_options)[0].resource_record_value
      type    = tolist(module.acm_certificate["carlssonk.com"].domain_validation_options)[0].resource_record_type
      ttl     = 60
      proxied = false
    }
    "carlssonk_1" = {
      name    = tolist(module.acm_certificate["carlssonk.com"].domain_validation_options)[1].resource_record_name
      value   = tolist(module.acm_certificate["carlssonk.com"].domain_validation_options)[1].resource_record_value
      type    = tolist(module.acm_certificate["carlssonk.com"].domain_validation_options)[1].resource_record_type
      ttl     = 60
      proxied = false
    }
  }
}
# for dvo in module.acm_certificate[each.value].domain_validation_options :

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.acm_certificate[var.domains_for_certificates[0]].arn


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
  count           = length(var.domains_for_certificates) > 1 ? length(var.domains_for_certificates) - 1 : 0
  listener_arn    = aws_lb_listener.front_end.arn
  certificate_arn = module.acm_certificate[var.domains_for_certificates[count.index + 1]].arn
}
