resource "aws_instance" "meet" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  user_data = base64encode(templatefile("${path.module}/install_scripts/install_jitsi.tpl", {
    setup_type                = "meet"
    region                    = var.aws_region
    jvb_secret                = local.jvb_secret
    hostname                  = local.xmpp_server
    xmpp_server               = local.xmpp_server
    xmpp_password             = local.xmpp_password
    email_address             = var.email_address
    admin_username            = var.admin_username
    admin_password            = var.admin_password
    jibri_installation_script = var.enable_recording_streaming ? templatefile("${path.module}/install_jibri.tpl", {}) : "echo \"Jibri installation is disabled\" >> /debug.txt"
    reboot_script             = var.enable_recording_streaming ? "echo \"Rebooting...\" >> /debug.txt\nreboot" : "echo \".\" >> /debug.txt"
  }))

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}

resource "aws_route53_record" "meet" {
  zone_id = data.aws_route53_zone.parent_subdomain.zone_id
  name    = "${var.aws_region}-meet.${var.subdomain}"
  type    = "A"
  ttl     = "300"

  records = [aws_instance.meet.public_ip]
}
