resource "aws_vpc_security_group_ingress_rule" "this" {
  count             = length(var.ingress_rules)
  security_group_id = var.security_group_id

  ip_protocol                  = var.ingress_rules[count.index].ip_protocol
  from_port                    = lookup(var.egress_rules[count.index], "from_port", null)
  to_port                      = lookup(var.egress_rules[count.index], "to_port", null)
  cidr_ipv4                    = lookup(var.egress_rules[count.index], "cidr_ipv4", null)
  cidr_ipv6                    = lookup(var.egress_rules[count.index], "cidr_ipv6", null)
  prefix_list_id               = lookup(var.egress_rules[count.index], "prefix_list_id", null)
  referenced_security_group_id = lookup(var.egress_rules[count.index], "referenced_security_group_id", null)
  description                  = lookup(var.egress_rules[count.index], "description", null)

  tags = {
    Name = "${var.name}-ingress-${count.index}"
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count             = length(var.egress_rules)
  security_group_id = var.security_group_id

  ip_protocol                  = var.ingress_rules[count.index].ip_protocol
  from_port                    = lookup(var.egress_rules[count.index], "from_port", null)
  to_port                      = lookup(var.egress_rules[count.index], "to_port", null)
  cidr_ipv4                    = lookup(var.egress_rules[count.index], "cidr_ipv4", null)
  cidr_ipv6                    = lookup(var.egress_rules[count.index], "cidr_ipv6", null)
  prefix_list_id               = lookup(var.egress_rules[count.index], "prefix_list_id", null)
  referenced_security_group_id = lookup(var.egress_rules[count.index], "referenced_security_group_id", null)
  description                  = lookup(var.egress_rules[count.index], "description", null)

  tags = {
    Name = "${var.name}-egress-${count.index}"
  }
}
