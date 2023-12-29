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
      xmpp    = join("-", concat(slice(pair, 0, 2), [local.profiles.xmpp]))
      domain  = "${join("-", pair)}.${local.fqdn}"
      region  = pair[0]
      shard   = pair[1]
      profile = pair[2]
      index   = pair[3]
    }
  ]
  services_meta = [
    for index, service in local.services : {
      install = templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
        profile      = local.services[index].profile
        github_token = var.github_token
        env_file = templatefile("${path.module}/templates/.env.tpl", {
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

variable "aws_region_mappings" {
  type = map(string)
  default = {
    "af-south-1"     = "afs1"
    "ap-east-1"      = "ape1"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "aps1"
    "ap-south-2"     = "aps2"
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ca-central-1"   = "cac1"
    "ca-west-1"      = "caw1"
    "eu-central-1"   = "euc1"
    "eu-central-2"   = "euc2"
    "eu-north-1"     = "eun1"
    "eu-south-1"     = "eus1"
    "eu-south-2"     = "eus2"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "il-central-1"   = "ilc1"
    "me-central-1"   = "mec1"
    "me-south-1"     = "mes1"
    "sa-east-1"      = "sae1"
    "us-east-1"      = "use1"
    "us-east-2"      = "use2"
    "us-gov-east-1"  = "usge1"
    "us-gov-west-1"  = "usgw1"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
  }
}
