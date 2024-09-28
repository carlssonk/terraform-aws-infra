resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]

  dynamic "instance_market_options" {
    for_each = var.use_spot ? ["x"] : []
    content {
      market_type = "spot"
      spot_options {
        max_price          = try(tostring(var.spot_max_price), null)
        spot_instance_type = try(var.spot_instance_type, null)
        # instance_interruption_behavior = try(var.spot_instance_interruption_behavior, null) -> InvalidParameterCombination: The terminate InstanceInterruptionBehavior is not supported when requestType is set to persistent
        instance_interruption_behavior = "stop"
      }
    }
  }

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
