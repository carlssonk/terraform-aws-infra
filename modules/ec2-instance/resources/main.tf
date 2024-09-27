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

// By default the instance will stop every time we edit the user_data so tis will boot it again
resource "null_resource" "reboot_trigger" {
  triggers = {
    instance_id = aws_instance.this.id
    user_data   = var.user_data
  }

  provisioner "local-exec" {
    command = "aws ec2 start-instances --instance-ids ${aws_instance.this.id}"
  }
}
