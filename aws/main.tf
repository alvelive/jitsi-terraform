locals {
  shards   = ["main"]
  profiles = ["xmpp", "jicofo", "jvb"]
  setup = [
    for pair in setproduct(var.aws_regions, local.shards, local.profiles) : {
      region  = pair[0]
      shard   = pair[1]
      profile = pair[2]
    }
  ]
}

module "jitsi" {
  count = length(local.setup)

  source = "./jitsi"

  domain       = var.domain
  subdomain    = var.subdomain
  ssh_key_name = var.ssh_key_name
  region       = local.setup[count.index].region
  shard        = local.setup[count.index].shard
  profile      = local.setup[count.index].profile
}
