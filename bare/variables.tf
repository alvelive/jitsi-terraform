variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "aws_region" {
  type        = string
  description = "AWS Regions to deploy instances"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Will be used to add route53 name servers to domain's zone"
}

variable "github_token" {
  type        = string
  description = "Will be used to clone the alvelive/docker-jitsi-meet repository"
}

variable "email" {
  description = "Email to be used for SSL certificate generation using Let's Encrypt"
  type        = string
  default     = "accounts@osoci.com"
}

variable "public_key" {
  type        = string
  description = "Will be intalled to the newly created instances, you should provide your public key's path"
}

variable "domain" {
  description = "Application domain, http server will be hosted at meet.{{ domain }} "
  type        = string
}

variable "subdomain" {
  description = "Subdomain for instances such as eu1-jvb.{{ subdomain }}.{{ domain }}"
  type        = string
}

variable "aws_region_mappings" {
  type = map(string)
  default = {
    "af-south-1"     = "afs1"
    "ap-east-1"      = "ape1"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "aps1"
    "ap-south-2"     = "aps2"
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ca-central-1"   = "cac1"
    "ca-west-1"      = "caw1"
    "eu-central-1"   = "euc1"
    "eu-central-2"   = "euc2"
    "eu-north-1"     = "eun1"
    "eu-south-1"     = "eus1"
    "eu-south-2"     = "eus2"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "il-central-1"   = "ilc1"
    "me-central-1"   = "mec1"
    "me-south-1"     = "mes1"
    "sa-east-1"      = "sae1"
    "us-east-1"      = "use1"
    "us-east-2"      = "use2"
    "us-gov-east-1"  = "usge1"
    "us-gov-west-1"  = "usgw1"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
  }
}
