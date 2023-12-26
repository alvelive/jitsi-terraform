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
