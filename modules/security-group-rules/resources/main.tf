resource "aws_vpc_security_group_ingress_rule" "this" {
  count             = length(var.ingress_rules)
  security_group_id = aws_security_group.this.id

  description                  = var.ingress_rules[count.index].description
  from_port                    = var.ingress_rules[count.index].from_port
  to_port                      = var.ingress_rules[count.index].to_port
  ip_protocol                  = var.ingress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.ingress_rules[count.index].cidr_ipv6
  prefix_list_id               = var.ingress_rules[count.index].prefix_list_id
  referenced_security_group_id = var.ingress_rules[count.index].referenced_security_group_id

  tags = {
    Name = "${var.name}-ingress-${count.index}"
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = length(var.egress_rules)

  security_group_id = aws_security_group.this.id

  description                  = var.egress_rules[count.index].description
  from_port                    = var.egress_rules[count.index].from_port
  to_port                      = var.egress_rules[count.index].to_port
  ip_protocol                  = var.egress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.egress_rules[count.index].cidr_ipv6
  prefix_list_id               = var.egress_rules[count.index].prefix_list_id
  referenced_security_group_id = var.egress_rules[count.index].referenced_security_group_id

  tags = {
    Name = "${var.name}-egress-${count.index}"
  }
}
