locals {
  allow_https_to_vpc_endpoints = {
    description     = "Allow HTTPS to VPC endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.security_group_vpc_endpoints.id]
  }

  allow_https_to_anywhere = {
    description = "Allow HTTPS to any destination"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ecs_ports = {
    "3000" = {
      value        = 3000
      egress_rules = [allow_https_to_vpc_endpoints, allow_https_to_anywhere]
    }
    "8080" = {
      value        = 8080
      egress_rules = [allow_https_to_vpc_endpoints]
    }
  }

  carlssonk_com = "carlssonk.com"

  apps = {
    portfolio = {
      root_domain = local.carlssonk_com
      domain_name = "www.${local.carlssonk_com}"
    }
    blackjack = {
      root_domain    = local.carlssonk_com
      container_port = local.ecs_ports["3000"].value
    }
  }

  cloudflare_ruleset_rules = [
    {
      action = "set_ssl"
      action_parameters = {
        value = "flexible"
      }
      expression = "(http.host eq \"${local.apps.portfolio.root_domain}\" or http.host eq \"${local.apps.portfolio.domain_name}\")"
    }
  ]
}
