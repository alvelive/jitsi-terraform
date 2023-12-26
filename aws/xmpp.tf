variable "xmpp_server_suffix" {
  description = "Suffix for XMPP server's subdomain"
  type        = string
  default     = "xmpp"
}

locals {
  xmpp_server_names = [for aws_region in var.aws_regions : "${var.aws_region_mappings[aws_region]}-${var.xmpp_server_suffix}"]
}

resource "aws_instance" "xmpp" {
  count         = length(local.xmpp_server_names)
  instance_type = "t3.medium"
  ami           = data.aws_ami.latest_ubuntu.id
  key_name      = var.ssh_key_name
  subnet_id     = aws_subnet.main[count.index].id
  user_data = base64encode(templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
    setup_type                = "xmpp"
    region                    = var.aws_regions[count.index]
    jvb_secret                = local.jvb_secret
    hostname                  = local.xmpp_server_names[count.index]
    xmpp_server               = local.xmpp_server_names[count.index]
    xmpp_password             = local.xmpp_password
    email_address             = var.email_address
    admin_username            = var.admin_username
    admin_password            = local.admin_password
    jibri_installation_script = var.enable_recording_streaming ? templatefile("${path.module}/install_jibri.tpl", {}) : "echo \"Jibri installation is disabled\" >> /debug.txt"
    reboot_script             = var.enable_recording_streaming ? "echo \"Rebooting...\" >> /debug.txt\nreboot" : "echo \".\" >> /debug.txt"
  }))

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  xmpp_ports = [
    80,
    5000,
    5222,
    5269,
    5280,
    5281,
    5347,
    5582
  ]
}

resource "aws_security_group" "xmpp_server_sg" {
  name        = "xmpp_server_security_group"
  description = "Security group for XMPP server"

  dynamic "ingress" {
    for_each = local.xmpp_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "xmpp" {
  count             = length(local.xmpp_server_names)
  domain_name       = "${local.xmpp_server_names[count.index]}.${var.subdomain}.${var.domain}"
  validation_method = "DNS"
  tags = {
    Name = "XMPP Server Certificate for ${local.xmpp_server_names[count.index]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  xmpp_records = flatten([
    for idx, cert in aws_acm_certificate.xmpp : [
      for dvo in cert.domain_validation_options : {
        domain_name           = dvo.domain_name
        resource_record_name  = dvo.resource_record_name
        resource_record_value = dvo.resource_record_value
        resource_record_type  = dvo.resource_record_type
      }
    ]
  ])
}

resource "aws_route53_record" "xmpp_certs" {
  for_each = { for record in local.xmpp_records : record.domain_name => record }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = aws_route53_zone.public.zone_id
}

resource "aws_route53_record" "xmpp_servers" {
  count   = length(local.xmpp_server_names)
  zone_id = aws_route53_zone.public.zone_id
  name    = local.xmpp_server_names[count.index]
  type    = "A"
  ttl     = 300
  records = [aws_instance.xmpp[count.index].public_ip]
}
