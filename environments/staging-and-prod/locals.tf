locals {
  root_domains = {
    carlssonk_com = "carlssonk.com"
  }

  env_subdomain_prefx = var.environment == "prod" ? "" : "${var.environment}."

  s3-websites = {
    portfolio = {
      app_name         = "portfolio"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = var.environment == "prod" ? "www" : var.environment
      github_repo_name = "carlssonk/website"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    fps = {
      app_name         = "first-person-shooter"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "${local.env_subdomain_prefx}fps"
      github_repo_name = "carlssonk/fps"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    terraform = {
      app_name         = "terraform-diagram"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "${local.env_subdomain_prefx}terraform"
      github_repo_name = "carlssonk/terraform-diagram"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
  }

  fargate-services = {
    blackjack = {
      app_name                = "blackjack"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "${local.env_subdomain_prefx}blackjack"
      github_repo_name        = "carlssonk/Blackjack-Game-Multiplayer"
      container_port          = 8080
      use_stickiness          = true
      assign_public_ip        = true
      fargate_spot_percentage = var.fargate_spot_percentage
      cloudflare = {
        ssl_mode = var.reverse_proxy_type == "nginx" ? "flexible" : null
      }
    }
    flagracer = {
      app_name                = "flag-racer"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "${local.env_subdomain_prefx}flagracer"
      github_repo_name        = "carlssonk/flag-racer"
      container_port          = 8080
      use_stickiness          = true
      assign_public_ip        = true
      fargate_spot_percentage = var.fargate_spot_percentage
      cloudflare = {
        ssl_mode = var.reverse_proxy_type == "nginx" ? "flexible" : null
      }
    }
  }

  apps = merge(local.s3-websites, local.fargate-services)
}
