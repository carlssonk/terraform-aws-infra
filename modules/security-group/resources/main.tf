resource "aws_security_group" "this" {
  name_prefix = "${var.name}-sg-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
