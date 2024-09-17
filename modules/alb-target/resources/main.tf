resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-tg-new"
  port        = var.container_port
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    matcher = "200"
    path    = "/health"
    port    = var.container_port
  }

  dynamic "stickiness" {
    for_each = var.use_stickiness ? [1] : [0]
    content {
      type            = "lb_cookie"
      cookie_duration = 86400
      enabled         = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.host_header]
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.app_name}-tg-rule"
  }
}
