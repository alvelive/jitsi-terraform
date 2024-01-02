locals {
  regions = [local.region]
  shards  = ["a"]
  profiles = {
    xmpp   = "xmpp"
    jicofo = "jicofo"
    jvb    = "jvb"
  }
  region = var.aws_region_mappings[var.aws_region]
  master = setproduct(local.regions, local.shards, [local.profiles.xmpp], [""])
  jicofo = setproduct(local.regions, local.shards, [local.profiles.jicofo], [""])
  jvb    = setproduct(local.regions, local.shards, [local.profiles.jvb], ["1", "2", "3"])

  premeta1 = [
    for pair in concat(local.master, local.jicofo, local.jvb) : {
      region  = pair[0]
      shard   = pair[1]
      profile = pair[2]
      replica = pair[3]
    }
  ]

  premeta2 = [
    for service in local.premeta1 : merge(service, {
      prefix = "${service.region}${service.shard}"
      suffix = "${service.profile}${service.replica}"
    })
  ]

  premeta3 = [
    for service in local.premeta2 : merge(service, {
      id          = "${service.prefix}-${service.suffix}"
      xmpp_domain = "${service.prefix}-${local.profiles.xmpp}.${local.fqdn}"
    })
  ]

  premeta4 = [
    for service in local.premeta3 : merge(service, {
      domain = "${service.id}.${local.fqdn}"
    })
  ]

  premeta5 = [
    for service in local.premeta4 : merge(service, {
      url = "https://${service.domain}"
      env_file = templatefile("${path.module}/templates/env.sh", {
        domain                  = service.domain
        region                  = service.region
        shard                   = service.shard
        xmpp_domain             = service.xmpp_domain
        email                   = var.email
        jwt_app_secret          = local.random.jwt_app_secret
        jicofo_auth_password    = local.random.jicofo_auth_password
        jvb_auth_password       = local.random.jvb_auth_password
        jicofo_component_secret = local.random.jicofo_component_secret
      })
    })
  ]

  premeta6 = [
    for service in local.premeta5 : merge(service, {
      install_script = templatefile("${path.module}/templates/install_jitsi.sh", {
        profile      = service.profile
        env_file     = service.env_file
        github_token = var.github_token
      })
    })
  ]


  meta = [
    for index, service in local.premeta6 : merge(service, {
      target = "${path.module}/install/${service.id}.sh"
      user_data = templatefile("${path.module}/templates/create_install_script.sh", {
        install_script = service.install_script
      })
    })
  ]
}

output "install_scripts" {
  value = local.meta[*].user_data
}

output "services" {
  value = local.meta[*].domain
}

output "endpoints" {
  value = local.meta[*].url
}

resource "null_resource" "write_to_file" {
  count    = length(local.meta)
  triggers = { meta = local.meta[count.index].user_data }

  provisioner "local-exec" {
    command     = <<-EOT
      mkdir -p install
      cat <<'EOF' >${local.meta[count.index].target}
      ${local.meta[count.index].user_data}
      EOF
    EOT
    interpreter = ["bash", "-c"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "jitsi-${local.fqdn}"
  public_key = file(var.public_key)
}

resource "aws_instance" "services" {
  depends_on                  = [aws_route_table_association.route_table_association]
  count                       = length(local.meta)
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.jitsi.id]
  subnet_id                   = aws_subnet.main.id
  user_data                   = base64encode(local.meta[count.index].user_data)
  associate_public_ip_address = true

  tags = {
    Name = local.meta[count.index].domain
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "lb" {
  count    = length(local.meta)
  instance = aws_instance.services[count.index].id
  domain   = "vpc"
}

resource "aws_route53_record" "master_a" {
  count           = length(local.meta)
  zone_id         = aws_route53_zone.public.zone_id
  name            = local.meta[count.index].id
  type            = "A"
  ttl             = 300
  records         = [aws_eip.lb[count.index].public_ip]
  allow_overwrite = true
}
