variable "aws_profile" {
  description = "AWS Credentials profile"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS Region where this server will be hosted"
  type        = string
  default     = "eu-south-1"
}
variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
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

variable "admin_password" {
  description = "Password for moderator user. Only this user will be allowed to start meets."
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


variable "subdomain" {
  description = "(Optional) Subdomain under a parent domain to host this instance"
  type        = string
  default     = "dev.meet"
}

variable "parent_subdomain" {
  description = "Parent domain/subdomain. Server will be hosted at https://<UUIDv4>.parent_subdomain"
  type        = string
  default     = "alve.live"
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

variable "vpc_id" {
  type    = string
  default = "vpc-0dd39374d101e798a"
}

variable "subnet_ids" {
  type = list(string)
  default = [
    "subnet-0dcdd8851d084f5ae",
    "subnet-062678f1b2140fd3e",
    "subnet-0c062e0020d01bd05"
  ]
}

variable "ami_id" {
  type    = string
  default = "ami-056bb2662ef466553"
}
