output "policy_documents" {
  value = [module.main_vpc.policy_document]
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
