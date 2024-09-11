variable "app_name" {
  description = "Name of application"
}

variable "port" {
  description = "Should match container port"
}

variable "vpc_id" {
  description = "ID of vpc"
}

variable "listener_arn" {
  description = "ARN of alb listener"
}

resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-tg"
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
