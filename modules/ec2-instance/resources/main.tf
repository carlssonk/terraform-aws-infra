resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]

  user_data = var.user_data

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
