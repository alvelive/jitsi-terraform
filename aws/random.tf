resource "random_id" "jwt_app_secret" {
  byte_length = 16
}

resource "random_id" "jicofo_auth_password" {
  byte_length = 16
}

resource "random_id" "jvb_auth_password" {
  byte_length = 16
}

resource "random_id" "jicofo_component_secret" {
  byte_length = 16
}

locals {
  random = {
    jwt_app_secret          = random_id.jwt_app_secret.hex
    jicofo_auth_password    = random_id.jicofo_auth_password.hex
    jvb_auth_password       = random_id.jvb_auth_password.hex
    jicofo_component_secret = random_id.jicofo_component_secret.hex
  }
}

output "jwt_app_secret" {
  value = local.random.jwt_app_secret
}
