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
