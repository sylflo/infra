
module "aws_backend" {
  source      = "./aws_backend"

  bucket_name = var.bucket_name
}

module "cloudflare" {
  source              = "./cloudflare"

  email               = var. cloudflare_email
  api_token           = var.cloudflare_api_token
  domain_name         = var.domain_name
  public_records      = [
    {
      name        = "bitwarden",
      ip_address  = var.public_ip_address
    },
    {
      name        = "ombi",
      ip_address  = var.public_ip_address
    },
    {
      name        = "stream",
      ip_address  = var.public_ip_address
    },
    {
      name        = "matomo",
      ip_address  = var.public_ip_address
    },
    {
     name         = "location",
     ip_address   = var.public_ip_address
    },
    {
     name         = "renting_back",
     ip_address   = var.public_ip_address
    }
  ]

  private_records      = [
    {
      name        = "deluge",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "jackett",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "sonarr",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "radarr",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "grafana-k8s",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "prometheus-k8s",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "alertmanager-k8s",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "foldingathome",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "router",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "switch",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "unifi",
      ip_address  = "192.168.10.20"
    },
    {
      name        = "cockpit",
      ip_address  = "192.168.10.20"
    },
  ]
}

module "misc" {
  source          = "./misc"

  ssh_user        = var.ssh_user
  server_name     = var.server_name
  public_ssh_key  = var.public_ssh_key
  vms = [
  ]
}

module "kubernetes" {
  source = "./kubernetes"

  server_name = var.server_name
  ssh_user    = var.ssh_user
  public_ssh_key = var.public_ssh_key
  vm_name_prefix = "k8s"
  vm_masters = [
    {
      memory      = "4096"
      cpu         = 2
      ip_address  = "192.168.100.10"
      ip_gateway  = "192.168.100.254"
      ip_dns      = "193.138.218.74"
    }
  ]
  vm_workers = [
    {
      memory      = "4096"
      cpu         = 2
      ip_address  = "192.168.100.20"
      ip_gateway  = "192.168.100.254"
      ip_dns      = "193.138.218.74"
      attach_disk = false
    },
    {
      memory      = "8192"
      cpu         = 2
      ip_address  = "192.168.100.21"
      ip_gateway  = "192.168.100.254"
      ip_dns      = "193.138.218.74"
      attach_disk = true
    }
  ]
}
