
provider "libvirt" {
  uri = "qemu+ssh://${var.ssh_user}@${var.server_name}/system?socket=/var/run/libvirt/libvirt-sock"
}

resource "libvirt_pool" "pfsense" {
  name = "pfsense"
  type = "dir"
  path = "/var/lib/libvirt/images/pfsense"
}

resource "libvirt_volume" "pfsense-disk" {
  name             = "pfsense.qcow2"
  format           = "qcow2"
  size             = 10000000000
  pool             = libvirt_pool.pfsense.name
}

resource "libvirt_domain" "pfsense" {
  name = "pfsense"
  autostart = true
  vcpu   = 1
  memory = 2048

  network_interface {
    bridge = "br0"
  }

  network_interface {
    bridge = "br10"
  }

  disk {
    file = "/var/lib/libvirt/images/pfsense/pfSense.iso"
  }

  disk {
    volume_id = libvirt_volume.pfsense-disk.id
    scsi      = "true"
  }

  boot_device {
    dev = [ "cdrom", "hd"]
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
