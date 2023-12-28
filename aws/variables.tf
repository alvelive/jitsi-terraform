variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "aws_regions" {
  type        = list(string)
  description = "AWS Regions to deploy instances"
}

variable "cloudflare_api_token" {
  type        = string
  description = "cloudflare_api_token"
}

variable "email_address" {
  description = "Email to be used for SSL certificate generation using Let's Encrypt"
  type        = string
  default     = "accounts@osoci.com"
}

variable "admin_username" {
  description = "Moderator username. Only this user will be allowed to start meets."
  type        = string
  default     = "admin"
}

variable "enable_ssh_access" {
  description = "Whether to allow SSH access or not. Requires SSH Key to be imported to AWS Console."
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "(Optional) SSH Key Pair name as set up in AWS. This is for debugging with SSH access."
  type        = string
  default     = null
}

variable "domain" {
  description = "Application domain, http server will be hosted at meet.{{ domain }} "
  type        = string
}

variable "subdomain" {
  description = "Subdomain for instances such as eu1-jvb.{{ subdomain }}.{{ domain }}"
  type        = string
}
