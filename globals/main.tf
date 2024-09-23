data "local_file" "globals" {
  filename = "${path.root}../../globals.json"
}

data "http" "cloudflare_ips_v4" {
  url = "https://www.cloudflare.com/ips-v4"
  request_headers = {
    Accept = "text/plain"
  }
}

data "http" "cloudflare_ips_v6" {
  url = "https://www.cloudflare.com/ips-v6"
  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  cloudflare_ipv4_ranges   = split("\n", chomp(try(data.http.cloudflare_ips_v4.response_body, "")))
  cloudflare_ipv6_ranges   = split("\n", chomp(try(data.http.cloudflare_ips_v6.response_body, "")))
  cloudflare_all_ip_ranges = concat(local.cloudflare_ipv4_ranges, local.cloudflare_ipv6_ranges)
}

output "var" {
  value = merge(
    jsondecode(data.local_file.globals.content),
    { cloudflare_all_ip_ranges : local.cloudflare_all_ip_ranges },
    { cloudflare_ipv4_ranges : local.cloudflare_ipv4_ranges },
    { cloudflare_ipv6_ranges : local.cloudflare_ipv6_ranges }
  )
}
