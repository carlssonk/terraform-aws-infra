variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

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
    8080 = {
      egress_rules = [allow_https_to_vpc_endpoints, allow_https_to_anywhere]
    }
    # 8081 = {
    #   egress_rules = [allow_https_to_vpc_endpoints]
    # }
  }

  apps = {
    portfolio = {
      cloudflare_ruleset_rules = [{
        action = "set_config"
        action_parameters = {
          ssl = "flexible"
        }
        expression  = "(http.host eq \"carlssonk.com\" or http.host eq \"www.carlssonk.com\")"
        description = "Cloudflare rules for portfolio"
      }]
    }
    diagram = {
      cloudflare_ruleset_rules = [{
        action = "set_config"
        action_parameters = {
          ssl = "flexible"
        }
        expression  = "(http.host eq \"terraform.carlssonk.com\")"
        description = "Cloudflare rules for diagram"
      }]
    }
  }
}
