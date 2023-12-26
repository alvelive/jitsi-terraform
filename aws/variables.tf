variable "aws_profile" {
  description = "AWS Credentials profile"
  type        = string
  default     = "default"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "aws_regions" {
  description = "AWS Regions to deploy instances"
  type        = list(string)
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


variable "enable_recording_streaming" {
  description = "Enables recording and streaming capability on Jitsi Meet"
  type        = bool
  default     = false
}

variable "record_all_streaming" {
  description = "(Optional) Records every stream if set to true"
  type        = bool
  default     = false
}

variable "recorded_stream_dir" {
  description = "(Optional) Base directory where recorded streams will be available."
  type        = string
  default     = "/var/www/html/recordings"
}

variable "facebook_stream_key" {
  description = "(Optional) Stream Key for Facebook"
  type        = string
  default     = ""
}

variable "periscope_server_url" {
  description = "(Optional) Periscope streaming server base URL"
  type        = string
  default     = "rtmp://in.pscp.tv:80/x"
}

variable "periscope_stream_key" {
  description = "(Optional) Streaming key for Periscope"
  type        = string
  default     = ""
}

variable "youtube_stream_key" {
  description = "(Optional) YouTube stream key"
  type        = string
  default     = ""
}

variable "twitch_ingest_endpoint" {
  description = "(Optional) Ingest endpoint for Twitch. E.g. rtmp://live-mrs.twitch.tv/app"
  default     = "rtmp://live-sin.twitch.tv/app"
}

variable "twitch_stream_key" {
  description = "(Optional) Streaming key for Twitch"
  default     = ""
}

variable "rtmp_stream_urls" {
  description = "(Optional) A list of generic RTMP URLs for streaming"
  type        = list(any)
  default     = []
}
