
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
  required_version = ">= 0.13"
}

provider "libvirt" {
  uri = "qemu+ssh://${var.ssh_user}@${var.server_name}/system?socket=/var/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "misc" {
  name = "misc"
  type = "dir"
  path = "/var/lib/libvirt/images/misc"
}

resource "libvirt_pool" "cloud_init" {
  name = "cloud-init"
  type = "dir"
  path = "/var/lib/libvirt/images/cloud-init"
}

resource "libvirt_volume" "ubuntu-qcow2" {
  count   = length(var.vms) 

  name    = "${var.vms[count.index].name}-qcow2"
  pool    = libvirt_pool.misc.name
  source  = var.source_img
  format  = "qcow2"
}

data "template_file" "user_data" {
  count     = length(var.vms) 

  template  = file("${path.module}/templates/cloud_init.yaml")
  vars = {
    hostname        = var.vms[count.index].name
    public_ssh_key  = file(var.public_ssh_key)
  }
}

data "template_file" "network_config" {
  count     = length(var.vms) 

  template  = file("${path.module}/templates/network_config.yaml")
  vars = {
    ip_address = var.vms[count.index].ip_address
    ip_gateway = var.vms[count.index].ip_gateway
    ip_dns     = var.vms[count.index].ip_dns
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count           = length(var.vms)

  name            = "${var.vms[count.index].name}.iso"
  user_data       = element(data.template_file.user_data.*.rendered, count.index)
  network_config  = element(data.template_file.network_config.*.rendered, count.index)
  pool             = libvirt_pool.cloud_init.name
}

# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  count         = length(var.vms)

  name          = var.vms[count.index].name
  autostart     = true
  memory        = var.vms[count.index].memory
  vcpu          = var.vms[count.index].cpu

  cloudinit     = element(libvirt_cloudinit_disk.commoninit.*.id, count.index)

  network_interface {
    bridge      = "br0"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "tcp"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id   = element(libvirt_volume.ubuntu-qcow2.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain
