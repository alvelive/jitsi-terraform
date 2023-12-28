variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "shard" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

locals {
  id   = "${var.region}-${var.profile}-${var.shard}"
  xmpp = "${var.region}-${var.shard}-xmpp"
}

resource "aws_instance" "jitsi" {
  ami             = data.aws_ami.latest_ubuntu.id
  instance_type   = "t3.medium"
  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.jitsi.name]
  user_data = base64encode(
    templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
      profile = var.profile
      env_file = templatefile("${path.module}/templates/.env.tpl", {
        domain                  = "${local.id}.${var.subdomain}.${var.domain}"
        region                  = var.region
        shard                   = var.shard
        email                   = "accounts@osoci.com"
        xmpp_domain             = "${local.xmpp}.${var.subdomain}.${var.domain}"
        jwt_app_secret          = local.random.jwt_app_secret
        jicofo_auth_password    = local.random.jicofo_auth_password
        jvb_auth_password       = local.random.jvb_auth_password
        jicofo_component_secret = local.random.jicofo_component_secret
      })
    })
  )
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "service" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.id
  type    = "A"
  ttl     = 300
  records = [aws_instance.jitsi.public_ip]
}

output "instance" {
  value = aws_instance.jitsi
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
