resource "random_id" "jicofo_auth_password" {
  byte_length = 16
}
resource "random_id" "jvb_auth_password" {
  byte_length = 16
}
resource "random_id" "jwt_app_secret" {
  byte_length = 16
}
resource "random_id" "key_name" {
  byte_length = 16
}
resource "random_id" "password" {
  byte_length = 16
}
resource "random_id" "ssh_key_name" {
  byte_length = 16
}

locals {
  random = {
    jicofo_auth_password = random_id.jicofo_auth_password.hex
    jvb_auth_password    = random_id.jvb_auth_password.hex
    jwt_app_secret       = random_id.jwt_app_secret.hex
    key_name             = random_id.key_name.hex
    password             = random_id.password.hex
    ssh_key_name         = random_id.ssh_key_name.hex
  }
}
