output "policy_documents" {
  value = [module.main_vpc.policy_document, try(module.fck-nat[0].policy_document, null)]
}

output "main_vpc_id" {
  value = module.main_vpc.id
}

output "main_vpc_private_subnet_ids" {
  value = module.main_vpc.private_subnet_ids
}

output "main_vpc_public_subnet_ids" {
  value = module.main_vpc.public_subnet_ids
}

output "main_vpc_private_route_table_ids" {
  value = module.main_vpc.private_route_table_ids
}

output "main_vpc_public_route_table_ids" {
  value = module.main_vpc.public_route_table_ids
}

output "main_vpc_dns_resolver_ip" {
  value = module.main_vpc.dns_resolver_ip
}
