resource "aws_route53_zone" "public" {
  name = local.fqdn

  lifecycle {
    create_before_destroy = true
  }
}

data "cloudflare_zone" "public" {
  name = var.domain
}

locals {
  ns_records = [0, 1, 2, 3]
}

resource "cloudflare_record" "public_ns" {
  count = length(local.ns_records)

  zone_id = data.cloudflare_zone.public.id
  name    = var.subdomain
  type    = "NS"
  ttl     = 86400
  value   = aws_route53_zone.public.name_servers[count.index]
}
