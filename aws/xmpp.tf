locals {
  profiles = ["xmpp", "jicofo", "jvb"]
  variations = [
    for region, profile in setproduct(var.aws_regions, local.profiles) : {
      region  = region
      profile = profile
    }
  ]
}

resource "aws_instance" "misc" {
  count         = length(local.variations)
  depends_on    = [null_resource.environment[count.index]]
  instance_type = "t3.medium"
  ami           = data.aws_ami.latest_ubuntu.id
  key_name      = var.ssh_key_name
  subnet_id     = aws_subnet.main[count.index].id
  user_data = base64encode(
    templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
      profile  = local.variations[count.index].profile
      env_file = ""
    })
  )

  tags = {
    Name = "${local.variations[count.index].region} ${local.variations[count.index].profile}"
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "xmpp_servers" {
  count   = length(local.variations)
  zone_id = aws_route53_zone.public.zone_id
  name    = "${local.variations[count.index].region}-${local.variations[count.index].profile}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.xmpp[count.index].public_ip]
}
