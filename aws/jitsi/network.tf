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
    80,
    443,
    5222,
    5269,
    5280,
    5347,
    8080,
    8888,
    10000,
  ]
}

resource "aws_security_group" "jitsi" {
  name        = "jitsi sg"
  description = "jitsi security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5222
    to_port     = 5222
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5269
    to_port     = 5269
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5280
    to_port     = 5280
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5347
    to_port     = 5347
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
