resource "random_id" "jibriauthpass" {
  byte_length = 8
}

resource "random_id" "jibrirecorderpass" {
  byte_length = 8
}

resource "random_id" "server_id" {
  byte_length = 4
}

resource "random_id" "xmpp_password" {
  byte_length = 16
}

resource "random_id" "jvb_secret" {
  byte_length = 16
}

resource "random_id" "admin_password" {
  byte_length = 16
}

locals {
  jvb_secret     = random_id.jvb_secret.hex
  xmpp_password  = random_id.xmpp_password.hex
  admin_password = random_id.admin_password.hex
}
