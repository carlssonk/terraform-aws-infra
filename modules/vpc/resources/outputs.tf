output "id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  value = aws_route_table.private[*].id
}

output "public_route_table_ids" {
  value = aws_route_table.public[*].id
}

# The DNS server for a VPC is always at the base of the VPC network range, plus 2
// eg. 10.0.0.0/16 -> 10.0.0.2
output "dns_resolver_ip" {
  value = cidrhost(var.vpc_cidr, 2)
}
