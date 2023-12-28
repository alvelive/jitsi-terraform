# Creates an environment file in each region
resource "null_resource" "environment" {
  count = length(var.aws_regions)

  provisioner "local-exec" {
    command = <<-EOT
      echo <<EOF > .env.${var.aws_regions[count.index]}
      ${templatefile("${path.module}/templates/.env.tpl", {
    setup_type = "xmpp"
    # Frontend (web service)
    deploymentinfo_environment      = "production"
    deploymentinfo_environment_type = "cloud"
    deploymentinfo_region           = var.aws_regions[count.index]
    deploymentinfo_shard            = "shard1"
    deploymentinfo_userregion       = var.aws_regions[count.index]

    enable_octo              = true
    enable_colibri_websocket = true
    enable_auth              = true
    enable_letsencrypt       = true
    letsencrypt_domain       = "your-domain-${var.aws_regions[count.index]}.com"
    letsencrypt_email        = "your-email@example.com"

    # XMPP server (prosody service)
    enable_octo = true
    enable_s2s  = true
    enable_auth = true

    xmpp_domain              = "xmpp.${var.aws_regions[count.index]}.com"
    xmpp_auth_domain         = "xmpp.${var.aws_regions[count.index]}.com"
    xmpp_guest_domain        = "guest.xmpp.${var.aws_regions[count.index]}.com"
    xmpp_muc_domain          = "muc.xmpp.${var.aws_regions[count.index]}.com"
    xmpp_internal_muc_domain = "internal-muc.xmpp.${var.aws_regions[count.index]}.com"

    jwt_app_id                     = "your-jwt-app-id"
    jwt_app_secret                 = "your-jwt-app-secret"
    jwt_accepted_issuers           = "issuer1,issuer2"
    jwt_accepted_audiences         = "audience1,audience2"
    jwt_allow_empty                = false
    jwt_auth_type                  = "token"
    jwt_enable_domain_verification = true
    jwt_token_auth_module          = "token_verification"

    log_level = "info"

    # Focus component (jicofo service)
    enable_octo          = true
    jicofo_octo_region   = var.aws_regions[count.index]
    jvb_xmpp_server      = "your-jvb-xmpp-server"
    enable_auth          = true
    jicofo_auth_password = "your-jicofo-auth-password"
    jicofo_auth_type     = "your-jicofo-auth-type"

    jwt_app_id                     = "your-jwt-app-id"
    jwt_app_secret                 = "your-jwt-app-secret"
    jwt_accepted_issuers           = "issuer1,issuer2"
    jwt_accepted_audiences         = "audience1,audience2"
    jwt_allow_empty                = false
    jwt_auth_type                  = "token"
    jwt_enable_domain_verification = true
    jwt_token_auth_module          = "token_verification"

    enable_visitors = true

    # Video Bridge (jvb service)
    enable_octo       = true
    jvb_auth_user     = "your-jvb-auth-user"
    jvb_auth_password = "your-jvb-auth-password"
    jvb_xmpp_server   = "your-jvb-xmpp-server"
    enable_auth       = true

    letsencrypt_domain = "your-domain-${var.aws_regions[count.index]}.com"
    letsencrypt_email  = "your-email@example.com"
})}
      EOF
    EOT
}
}
