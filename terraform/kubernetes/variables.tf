variable "source_img" {
  type = string
  default = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

variable "server_name" {
  type = string
}

variable "ssh_user" {
  type  = string
  description = "The username of the ssh user"
}

variable "vm_name_prefix" {
  type  = string
}

variable "public_ssh_key" {
  type  = string
}

variable "vm_masters" {
    description = "Master VM list"
    type        = list(object({
        memory      = string
        cpu         = number
        ip_address  = string
        ip_gateway  = string
        ip_dns      = string
    }))
}

variable "vm_workers" {
    description = "Master VM list"
    type        = list(object({
        memory      = string
        cpu         = number
        ip_address  = string
        ip_gateway  = string
        ip_dns      = string
    }))
}