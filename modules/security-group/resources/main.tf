resource "aws_security_group" "this" {
  name_prefix = "${var.name}-sg-"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-sg"
  }
}
