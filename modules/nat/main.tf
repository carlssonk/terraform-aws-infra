module "fck-nat" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.3.0"
  count   = coalesce(var.subnet_count, 0)

  name               = "the-fck-nat-${count.index}"
  vpc_id             = var.vpc_id
  subnet_id          = var.public_subnet_ids[count.index]
  instance_type      = var.fck_nat_settings.instance_type
  ha_mode            = coalesce(try(var.fck_nat_settings.high_availability, false), false)
  use_spot_instances = coalesce(try(var.fck_nat_settings.use_spot, false), false)

  update_route_tables = true
  route_tables_ids = {
    private = var.private_route_table_ids[count.index]
  }

  tags = {
    Name = "the-fck-nat-${count.index}"
  }
}
