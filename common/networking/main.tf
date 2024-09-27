module "main_vpc" {
  source               = "../../modules/vpc/default"
  name                 = "main"
  use_single_subnet    = var.use_single_subnet
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "fck-nat" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.3.0"
  count   = var.workflow_step == "resources" && var.nat_type == "fck-nat" ? module.main_vpc.subnet_count : 0

  name               = "main-fck-nat"
  vpc_id             = module.main_vpc.id
  subnet_id          = module.main_vpc.public_subnet_ids[count.index]
  instance_type      = var.fck_nat_settings.instance_type
  ha_mode            = coalesce(try(var.fck_nat_settings.high_availability, false), false)
  use_spot_instances = coalesce(try(var.fck_nat_settings.use_spot, false), false)

  update_route_tables = true
  route_tables_ids = {
    private = module.main_vpc.private_route_table_ids[count.index]
  }

  tags = {
    Name = "main-fck-nat-${count.index}"
  }
}
