resource "aws_vpc_endpoint" "ecr_api" {
  for_each = toset(var.endpoints)

  vpc_id              = var.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
}
