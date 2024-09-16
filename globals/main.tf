data "local_file" "globals" {
  filename = "${path.root}/globals.json"
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
  cloudflare_ip_ranges = concat(
    split("\n", chomp(try(data.http.cloudflare_ips_v4.response_body, ""))),
    split("\n", chomp(try(data.http.cloudflare_ips_v6.response_body, "")))
  )
}

output "var" {
  value = merge(
    jsondecode(data.local_file.globals.content),
    { cloudflare_ip_ranges : local.cloudflare_ip_ranges }
  )
}
