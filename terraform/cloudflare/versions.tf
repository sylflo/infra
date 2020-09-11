terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
      version = "~> 2.1.2"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.11.0"
    }
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
  required_version = ">= 0.13"
}
