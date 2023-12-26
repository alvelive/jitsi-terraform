provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  subdomain     = length(var.subdomain) == 0 ? random_id.server_id.hex : var.subdomain
  xmpp_server   = "${var.aws_region}-meet.${var.subdomain}.${var.parent_subdomain}"
  xmpp_password = random_id.xmpp_password.hex
  jvb_secret    = random_id.jvb_secret.hex
}

# data "template_file" "stream_record" {
#   template = file("./templates/jibri/stream_record.tpl")
#   vars = {
#     recorded_stream_dir = var.recorded_stream_dir
#   }
# }

# data "template_file" "facebook_stream" {
#   template = file("./templates/jibri/facebook_stream.tpl")
#   vars = {
#     facebook_stream_key = var.facebook_stream_key
#   }
# }

# data "template_file" "periscope_stream" {
#   template = file("./templates/jibri/periscope_stream.tpl")
#   vars = {
#     periscope_server_url = var.periscope_server_url
#     periscope_stream_key = var.periscope_stream_key
#   }
# }

# data "template_file" "twitch_stream" {
#   template = file("./templates/jibri/twitch_stream.tpl")
#   vars = {
#     twitch_ingest_endpoint = var.twitch_ingest_endpoint
#     twitch_stream_key      = var.twitch_stream_key
#   }
# }

# data "template_file" "youtube_stream" {
#   template = file("./templates/jibri/youtube_stream.tpl")
#   vars = {
#     youtube_stream_key = var.youtube_stream_key
#   }
# }

# data "template_file" "generic_streams" {
#   template = file("./templates/jibri/generic_stream.tpl")
#   count    = length(var.rtmp_stream_urls)
#   vars = {
#     stream_url = var.rtmp_stream_urls[count.index]
#   }
# }


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  availability_zone = "eu-south-1a"
  tags = {
    Name = "Default subnet for ${var.aws_region}"
  }
}

resource "aws_default_subnet" "default2" {
  availability_zone = "eu-south-1b"
  tags = {
    Name = "Default2 subnet for ${var.aws_region}"
  }
}

data "aws_route53_zone" "parent_subdomain" {
  name = var.parent_subdomain
}

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

resource "aws_security_group" "allow_connections_jitsi" {
  name        = "allow_connections_jitsi"
  description = "Allow traffic on UDP 10000 (JVB) TCP 443 (HTTPS) UDP 53 (DNS)"

  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3478
    to_port     = 3478
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "egress" {
    for_each = var.enable_recording_streaming ? [1] : []
    content {
      from_port   = 1935
      to_port     = 1936
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.enable_recording_streaming ? [1] : []
    content {
      from_port   = 1935
      to_port     = 1936
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  tags = {
    Name = "allow_connections_jitsi"
  }
}

data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
