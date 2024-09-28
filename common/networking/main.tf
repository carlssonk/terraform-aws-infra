module "main_vpc" {
  source               = "../../modules/vpc"
  name                 = "main"
  use_single_subnet    = var.use_single_subnet
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "fck-nat" {
  count                   = var.nat_type == "fck-nat" ? 1 : 0
  source                  = "../../modules/nat"
  subnet_count            = module.main_vpc.subnet_count
  private_route_table_ids = module.main_vpc.private_route_table_ids
  public_subnet_ids       = module.main_vpc.public_subnet_ids
  vpc_id                  = module.main_vpc.id

  fck_nat_settings = var.fck_nat_settings
}
