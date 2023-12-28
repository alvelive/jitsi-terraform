variable "domain" {
  type = string
}

variable "subdomain" {
  type = string
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-jammy-22.04-*"]
  }
}
