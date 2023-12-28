locals {
  shards = ["main"]
  profiles = ["xmpp", "jicofo", "jvb"]
  setup = [
    for pair in setproduct(var.aws_regions, local.profiles, local.shards) : {
      profile = pair[1]
      region = {
        long  = pair[0],
        short = var.aws_region_mappings[pair[0]]
      }
      shard = pair[2]
      domain = "${region.short}-${profile}.${var.subdomain}.${var.domain}"
    }
  ]
}

resource "aws_launch_configuration" "jitsi" {
  count           = length(local.setup)
  name            = "jitsi-launch-config"
  instance_type   = "t3.medium"
  image_id        = data.aws_ami.latest_ubuntu.id
  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.egress, aws_security_group.jitsi]
  user_data = base64encode(
    templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
      profile = local.setup[count.index].profile
      env_file = templatefile("${path.module}/templates/.env.tpl", {
        domain               = "${local.setup[count.index].domain}"
        region               = "${local.setup[count.index].region}"
        shard                = "${local.setup[count.index].region}${local.setup[count.index].shard}"
        email    = "accounts@osoci.com"
        xmpp_domain          = "${local.setup[count.index].domain}"
        jwt_app_secret       = local.random.jwt_app_secret
        region               = local.random.region
        jicofo_auth_password = local.random.jicofo_auth_password
        jvb_auth_password    = local.random.jicofo_component_secret
      })
    })
  )
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "jitsi" {
  count                = length(aws_launch_configuration.jitsi)
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = local.subnets
  launch_configuration = aws_launch_configuration.jitsi[count.index].id

  lifecycle {
    create_before_destroy = true
  }
}
