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
  subnets = [
    for subnet in aws_subnet.main : subnet.id
  ]
}



locals {
  ports = [
    5222,
    5269,
    5280,
    5347,
    80,
    8080,
    8888,
    10000
  ]
}

resource "aws_security_group" "egress" {
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

resource "aws_security_group" "jitsi" {
  count       = length(local.ports)
  name        = "jitsi-out"
  description = "jitsi-out security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = local.ports[count.index]
    to_port     = local.ports[count.index]
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
