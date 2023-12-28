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

variable "cloudflare_email" {
  type        = string
  description = "cloudflare_email"
}
variable "cloudflare_api_token" {
  type        = string
  description = "cloudflare_api_token"
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

