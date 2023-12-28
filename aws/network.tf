data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = "173.82.0.0/16"
  tags = {
    Name = "Federated Jitsi VPC"
  }


  lifecycle {
    create_before_destroy = true
  }
}

locals {
  zones = data.aws_availability_zones.available.names
}

resource "aws_subnet" "main" {
  count = length(local.zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "173.82.${count.index}.0/24"
  availability_zone       = local.zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}



locals {
  tcp = [
    5222,
    5269,
    5280,
    5347,
    80,
    8080,
    8888,
  ]
  udp = [10000]
}

resource "aws_security_group" "jitsi_out" {
  name        = "jitsi-out"
  description = "jitsi-out security group"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "jitsi_tcp" {
  count       = length(local.tcp)
  name        = "jitsi-tcp-in"
  description = "jitsi-tcp-in security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = local.tcp[count.index]
    to_port     = local.tcp[count.index]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "jitsi_udp" {
  count       = length(local.udp)
  name        = "jitsi-udp-in"
  description = "jitsi-udp-in security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = local.udp[count.index]
    to_port     = local.udp[count.index]
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
