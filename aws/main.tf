locals {
  shards = ["main"]
  profiles = {
    xmpp   = "xmpp"
    jicofo = "jicofo"
    jvb    = "jvb"
  }
  region = var.aws_region_mappings[var.aws_region]
  master = setproduct([local.region], local.shards, [local.profiles.xmpp], [1])
  jicofo = setproduct([local.region], local.shards, [local.profiles.jicofo], [1])
  jvb    = setproduct([local.region], local.shards, [local.profiles.jvb], [1, 2, 3])
  services = [
    for pair in concat(local.master, local.jicofo, local.jvb) : {
      id      = join("-", pair)
      xmpp    = join("-", [pair[0], pair[1], local.profiles.xmpp, 1])
      domain  = "${join("-", pair)}.${local.fqdn}"
      region  = pair[0]
      shard   = pair[1]
      profile = pair[2]
      index   = pair[3]
    }
  ]
  services_meta = [
    for index, service in local.services : {
      install = templatefile("${path.module}/templates/install_jitsi.sh", {
        profile      = local.services[index].profile
        github_token = var.github_token
        env_file = templatefile("${path.module}/templates/.env", {
          domain                  = service.domain
          region                  = service.region
          shard                   = service.shard
          email                   = var.email
          xmpp_domain             = "${service.xmpp}.${local.fqdn}"
          jwt_app_secret          = local.random.jwt_app_secret
          jicofo_auth_password    = local.random.jicofo_auth_password
          jvb_auth_password       = local.random.jvb_auth_password
          jicofo_component_secret = local.random.jicofo_component_secret
        })
      })
      url = "https://${service.domain}"
    }
  ]
}

output "services" {
  value = local.services[*].domain
}

output "endpoints" {
  value = local.services_meta[*].url
}

output "install_scripts" {
  value = local.services_meta[*].install
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "jitsi-${local.fqdn}"
  public_key = file(var.public_key)
}

resource "aws_instance" "services" {
  depends_on = [
    aws_route_table_association.route_table_association
  ]
  count                       = length(local.services)
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.jitsi.id]
  subnet_id                   = aws_subnet.main.id
  user_data                   = base64encode(local.services_meta[count.index].install)
  associate_public_ip_address = true

  tags = {
    Name = local.services[count.index].domain
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "lb" {
  count    = length(local.services)
  instance = aws_instance.services[count.index].id
  domain   = "vpc"
}

resource "aws_route53_record" "master_a" {
  count           = length(local.services)
  zone_id         = aws_route53_zone.public.zone_id
  name            = local.services[count.index].id
  type            = "A"
  ttl             = 300
  records         = [aws_eip.lb[count.index].public_ip]
  allow_overwrite = true
}
