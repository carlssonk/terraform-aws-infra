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

  depends_on = [null_resource.create_service_linked_role_spot]
}

// By default the instance will stop every time we edit the user_data so tis will boot it again
resource "null_resource" "reboot_trigger" {
  triggers = {
    instance_id = aws_instance.this.id
    user_data   = var.user_data
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 describe-instances --instance-ids ${self.triggers.instance_id} --query 'Reservations[].Instances[].State.Name' --output text | grep -q 'stopped' && \
      aws ec2 start-instances --instance-ids ${self.triggers.instance_id} || \
      echo "Instance is not in 'stopped' state, skipping start operation"
    EOT
  }
}

# Sets IAM permission by creating service linked role
resource "null_resource" "create_service_linked_role_spot" {
  count = var.use_spot == true ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      role_exists=$(aws iam get-role --role-name AWSServiceRoleForEC2Spot 2>&1 | grep -c 'NoSuchEntity')
      if [ $role_exists -eq 1 ]; then
        aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
      else
        echo "Service-linked role for EC2 Spot already exists"
      fi
    EOT
  }
}
