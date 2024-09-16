module "main_alb" {
  source                   = "../../modules/alb/default"
  name                     = "main"
  vpc_id                   = var.networking_outputs.main_vpc_id
  subnet_ids               = var.networking_outputs.main_vpc_public_subnet_ids
  security_group_id        = var.security_outputs.security_group_alb_id
  domains_for_certificates = ["carlssonk.com"]
}

module "main_ecs_cluster" {
  source       = "../../modules/ecs-cluster/default"
  cluster_name = "MainCluster"
}
