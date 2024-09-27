environment    = "prod"
aws_region     = "eu-north-1"
aws_account_id = "752502408032"
organization   = "carlssonk"

use_single_subnet  = true
reverse_proxy_type = "nginx"
nat_type           = "fck-nat"

fargate_spot_percentage = 100

nginx_proxy_instance_settings = {
  instance_type             = "t4g.nano"
  use_spot                  = true
  spot_max_price_multiplier = 0.5
  spot_instance_type        = "persistent"
}

fck_nat_settings = {
  instance_type     = "t4g.nano"
  use_spot          = true
  high_availability = false
}
