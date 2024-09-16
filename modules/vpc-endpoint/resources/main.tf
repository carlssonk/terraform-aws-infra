resource "aws_vpc_endpoint" "interface" {
  for_each = var.type == "interface" ? toset(var.endpoints) : []

  vpc_id              = var.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.type == "gateway" ? toset(var.endpoints) : []

  vpc_id            = var.vpc_id
  service_name      = each.value
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids
}
