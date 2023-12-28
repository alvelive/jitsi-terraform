resource "aws_route53_zone" "public" {
  name = "${var.subdomain}.${var.domain}"

  lifecycle {
    create_before_destroy = true
  }
}

data "cloudflare_zone" "public" {
  name = var.domain
}

resource "cloudflare_record" "public_ns" {
  count   = length(aws_route53_zone.public.name_servers)
  zone_id = data.cloudflare_zone.public.id
  name    = var.subdomain
  type    = "NS"
  value   = aws_route53_zone.public.name_servers[count.index]
  ttl     = 86400

  lifecycle {
    create_before_destroy = true
  }
}
