
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
      name        = "heimdall",
      ip_address  = var.public_ip_address
    },
    {
      name        = "matomo",
      ip_address  = var.public_ip_address
    },
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
  ]
}


module "pfsense" {
  source      = "./pfsense"

  ssh_user    = var.ssh_user
  server_name = var.server_name
}

module "misc" {
  source          = "./misc"

  ssh_user        = var.ssh_user
  server_name     = var.server_name
  public_ssh_key  = var.public_ssh_key
  vms = [
    {
      name        = "vpn",
      memory      = "512",
      cpu         = 1,
      ip_address  = "192.168.0.20"
      ip_gateway  = "192.168.0.254"
      ip_dns      = "193.138.218.74"
    },
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
      ip_address  = "192.168.10.20"
      ip_gateway  = "192.168.10.254"
      ip_dns      = "193.138.218.74"
    }
  ]
  vm_workers = [
    {
      memory      = "4096"
      cpu         = 2
      ip_address  = "192.168.10.30"
      ip_gateway  = "192.168.10.254"
      ip_dns      = "193.138.218.74"
      attach_disk = false
    },
    {
      memory      = "8192"
      cpu         = 2
      ip_address  = "192.168.10.31"
      ip_gateway  = "192.168.10.254"
      ip_dns      = "193.138.218.74"
      attach_disk = true
    }
  ]
}
