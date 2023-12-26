resource "aws_route53_zone" "public" {
  name = "${var.subdomain}.${var.domain}"

  lifecycle {
    create_before_destroy = true
  }
}
