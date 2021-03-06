variable "server_name" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "public_ssh_key" {
  type  = string
}

variable "vms" {
    description = "Misc VM list"
    type        = list(object({
        name        = string
        memory      = string
        cpu         = number
        ip_address  = string
        ip_gateway  = string
        ip_dns      = string
    }))
}

variable "source_img" {
  type = string
  default = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}
