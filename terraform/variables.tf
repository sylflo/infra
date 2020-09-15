#===============================================================================
# AWS backend
#===============================================================================

variable "bucket_name" {
  type        = string
  description = "Prefix of the bucket name and dynamodb"
}

#====================#
# Cloudlfare         #
#====================#

variable "public_ip_address" {
  type        = string
  description = "Ip address of public domain associated to the domain_name"
}

variable "domain_name" {
  type        = string
  description = "Domain name record for cloudflare associated to public_ip_address"
}

variable "cloudflare_email" {
  type        = string
  description = "Authentication email"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Authentication api token"
}

#====================#
# Libvirt            #
#====================#

variable "server_name" {
  type        = string
  description = "The name of the server"
}

variable "ssh_user" {
  type        = string
  description = "The username of the ssh user"

}

variable "public_ssh_key" {
 type         = string
  description = "The ssh key for cloud init vm"
}
