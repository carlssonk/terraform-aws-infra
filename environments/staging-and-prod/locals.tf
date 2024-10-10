locals {

  # Active environments
  environments = ["prod", "staging"]

  # Update as needed
  ec2_on_demand_hourly_rate = {
    eu-north-1 = {
      "t4g.nano" = 0.0043
    }
  }

  ec2_instances = {
    nginx_proxy_settings = merge(
      var.nginx_proxy_instance_settings,
      { spot_max_price = local.ec2_on_demand_hourly_rate[try(var.aws_region, "eu-north-1")][try(var.nginx_proxy_instance_settings.instance_type, "t4g.nano")] * var.nginx_proxy_instance_settings.spot_max_price_multiplier }
    )
  }

  root_domains = {
    carlssonk_com = "carlssonk.com"
  }


  s3_websites_config = {
    portfolio = {
      app_name         = "portfolio"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "www"
      github_repo_name = "carlssonk/website"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    fps = {
      app_name         = "first-person-shooter"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "fps"
      github_repo_name = "carlssonk/fps"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    terraform = {
      app_name         = "terraform-diagram"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "terraform"
      github_repo_name = "carlssonk/terraform-diagram"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
  }

  fargate_services_config = {
    blackjack = {
      app_name                = "blackjack"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "blackjack"
      github_repo_name        = "carlssonk/Blackjack-Game-Multiplayer"
      container_port          = 8080
      use_stickiness          = true
      fargate_spot_percentage = var.fargate_spot_percentage
      cloudflare = {
        ssl_mode = var.reverse_proxy_type == "nginx" ? "flexible" : null
      }
    }
    flagracer = {
      app_name                = "flag-racer"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "flagracer"
      github_repo_name        = "carlssonk/flag-racer"
      container_port          = 8080
      use_stickiness          = true
      fargate_spot_percentage = var.fargate_spot_percentage
      cloudflare = {
        ssl_mode = var.reverse_proxy_type == "nginx" ? "flexible" : null
      }
    }
    flare = {
      app_name                = "flare-messenger"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "messenger"
      github_repo_name        = "carlssonk/flare-messenger"
      container_port          = 8080
      use_stickiness          = true
      fargate_spot_percentage = var.fargate_spot_percentage
      cloudflare = {
        ssl_mode = var.reverse_proxy_type == "nginx" ? "flexible" : null
      }
    }
  }

  s3_media_config = {
    flare_media = {
      app_name    = "flare-messenger-media"
      bucket_name = "${var.organization}-${local.fargate_services_config.flare.app_name}-media"
      subdomain   = "messenger-cdn"
      root_domain = local.root_domains.carlssonk_com
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
  }

  env_subdomain_suffix = var.environment == "prod" ? "" : "-${var.environment}"

  # Apply subdomain prefix
  s3_websites = {
    for _, config in local.s3_websites_config :
    _ => merge(config, {
      subdomain = config.subdomain == "www" ? var.environment == "prod" ? config.subdomain : var.environment : "${config.subdomain}${local.env_subdomain_suffix}"
    })
  }
  fargate_services = {
    for _, config in local.fargate_services_config :
    _ => merge(config, {
      subdomain = config.subdomain == "www" ? var.environment == "prod" ? config.subdomain : var.environment : "${config.subdomain}${local.env_subdomain_suffix}"
    })
  }
  s3_media = {
    for _, config in local.s3_media_config :
    _ => merge(config, {
      subdomain = var.environment == "prod" ? config.subdomain : "${config.subdomain}${local.env_subdomain_suffix}"
    })
  }

  cloudflare_app_settings = merge(local.s3_websites_config, local.fargate_services_config, local.s3_media_config)
}
