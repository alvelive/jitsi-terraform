locals {
  random_byte_length = 32
}

resource "random_id" "jwt_app_secret" {
  byte_length = local.random_byte_length
}

resource "random_id" "jicofo_auth_password" {
  byte_length = local.random_byte_length
}

resource "random_id" "jvb_auth_password" {
  byte_length = local.random_byte_length
}

resource "random_id" "jicofo_component_secret" {
  byte_length = local.random_byte_length
}

locals {
  random = {
    jwt_app_secret          = random_id.jwt_app_secret.id
    jicofo_auth_password    = random_id.jicofo_auth_password.id
    jvb_auth_password       = random_id.jvb_auth_password.id
    jicofo_component_secret = random_id.jicofo_component_secret.id
  }
}

output "jwt_app_secret" {
  value = local.random.jwt_app_secret
}

output "jicofo_auth_password" {
  value = local.random.jicofo_auth_password
}

output "jvb_auth_password" {
  value = local.random.jvb_auth_password
}

output "jicofo_component_secret" {
  value = local.random.jicofo_component_secret
}
