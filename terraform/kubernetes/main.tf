
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

resource "libvirt_pool" "container-linux" {
  name  = "container-linux"
  type  = "dir"
  path  = "/var/lib/libvirt/images/container-linux"
}

resource "libvirt_pool" "cloud_init" {
  name = "cloud-init-k8s"
  type = "dir"
  path = "/var/lib/libvirt/images/cloud-init-container-linux"
}

#===============================================================================
# Master Libvirt Resources
#===============================================================================

# Create the master disk #
resource "libvirt_volume" "ubuntu_disk_master" {
  count             = length(var.vm_masters)

  name              = "ubuntu-master-${count.index + 1}.qcow2"
  pool              = libvirt_pool.container-linux.name
  source            = var.source_img
  format            = "qcow2"
}

data "template_file" "user_data_master" {
  count     = length(var.vm_masters) 

  template  = file("${path.module}/templates/cloud_init.yaml")
  vars = {
    hostname        = "master-${count.index}"
    public_ssh_key  = file(var.public_ssh_key)
  }
}

data "template_file" "network_config_master" {
  count     = length(var.vm_masters) 

  template  = file("${path.module}/templates/network_config.yaml")
  vars = {
    ip_address = var.vm_masters[count.index].ip_address
    ip_gateway = var.vm_masters[count.index].ip_gateway
    ip_dns     = var.vm_masters[count.index].ip_dns
  }
}

resource "libvirt_cloudinit_disk" "commoninit_master" {
  count           = length(var.vm_masters)

  name            = "master-${count.index}.iso"
  user_data       = element(data.template_file.user_data_master.*.rendered, count.index)
  network_config  = element(data.template_file.network_config_master.*.rendered, count.index)
  pool             = libvirt_pool.cloud_init.name
}

# Create the master virtual machines
resource "libvirt_domain" "ubuntu-machine_master" {
  count           = length(var.vm_masters)
  
  name            = "${var.vm_name_prefix}-master-${count.index}"
  vcpu            = var.vm_masters[count.index].cpu
  memory          = var.vm_masters[count.index].memory

  cloudinit       = element(libvirt_cloudinit_disk.commoninit_master.*.id, count.index)

  network_interface {
    bridge         = "br100"
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
    volume_id     = element(libvirt_volume.ubuntu_disk_master.*.id, count.index)
  }

}

# ===============================================================================
# Worker Libvirt Resources
# ===============================================================================

# Create the worker disk #
resource "libvirt_volume" "ubuntu_disk_worker" {
  count             = length(var.vm_workers)

  name              = "ubuntu-worker-${count.index + 1}.qcow2"
  pool              = libvirt_pool.container-linux.name
  source            = var.source_img
  format            = "qcow2"
}

data "template_file" "user_data_worker" {
  count     = length(var.vm_workers) 

  template  = file("${path.module}/templates/cloud_init.yaml")
  vars = {
    hostname        = "worker-${count.index}"
    public_ssh_key  = file(var.public_ssh_key)
  }
}

data "template_file" "network_config_worker" {
  count     = length(var.vm_workers) 

  template  = file("${path.module}/templates/network_config.yaml")
  vars = {
    ip_address = var.vm_workers[count.index].ip_address
    ip_gateway =  var.vm_workers[count.index].ip_gateway
    ip_dns     = var.vm_workers[count.index].ip_dns
  }
}

resource "libvirt_cloudinit_disk" "commoninit_worker" {
  count           = length(var.vm_workers)

  name            = "worker-${count.index}.iso"
  user_data       = element(data.template_file.user_data_worker.*.rendered, count.index)
  network_config  = element(data.template_file.network_config_worker.*.rendered, count.index)
  pool            = libvirt_pool.cloud_init.name
}

# Create the worker virtual machines
resource "libvirt_domain" "ubuntu-machine_worker" {
  count           = length(var.vm_workers)

  name            = "${var.vm_name_prefix}-worker-${count.index}"
  vcpu            = var.vm_workers[count.index].cpu
  memory          = var.vm_workers[count.index].memory

  cloudinit       = element(libvirt_cloudinit_disk.commoninit_worker.*.id, count.index)

  network_interface {
    bridge        = "br100"
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
    volume_id     = element(libvirt_volume.ubuntu_disk_worker.*.id, count.index)
  }
}
