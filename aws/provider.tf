provider "aws" {
  region     = "eu-south-1" # Specify the AWS region you want to use
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  # Other required and optional configuration parameters can be added here
}

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
