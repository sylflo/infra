variable "email" {
  type  = string
}

variable "api_token" {
  type  = string
}

variable "domain_name" {
  type  = string
}

variable "public_records" {
  type          = list(object({
    name        = string
    ip_address  = string
  }))
}

variable "private_records" {
  type          = list(object({
    name        = string
    ip_address  = string
  }))
}
