This project will configure an infra:

## Set the hypervisor

First you need to:
- check the inventory file
- copy your public ssh key
```
ssh-copy-id -i ~/.ssh/mykey user@hypervisor
```
- configure sudo on the host
```
apt install sudo
usermod -aG sudo username
```

Create a main.yaml for example
```
- name: Call playbook to install libvirt
  import_playbook: install_base.yaml
  vars:
    username: sylflo
    br0_ip_address: 192.168.0.11
    br0_ip_gateway: "192.168.0.254"
    pfsense_version: "pfSense-CE-2.4.5-RELEASE-amd64"
```

Launch this command to install libvirt and cockpit
```
cd base
ansible-galaxy install -r requirements.yml  # Install dependencies
ansible-playbook --ask-become-pass  -i ../inventory main.yaml
```

Once the reboot is done, do not forget to change the hypervisor ip address in the inventory file

## Create the infrastructure using Terraform

The infrastructure has multiple module:
- cloudflare: To create record
- pfsense: To create the pfsense vm
- misc: To install the wireguard vm and other vms
- kubernetes: To install the kubernetes vm and provision the cluster

### pfSense

Once the pfsense vm is created, you will have to use the following commands:
```
virsh edit pfsense
```

You have to remove the cdrom boot so the vm can boot on the hard disk
Once this is done, you need to reboot the vm and copy the old config (if you have one)

### VPN (Wireguard)

Once the vpn vm is created, you will need to install wireguard


### Kubernetes

#### Prepare cluster

Once the vm are created:

- attach /dev/sdx (disk only for data) to worker-1, example

`sudo mkdir  /var/lib/rancher/k3s/storage`

```
/etc/fstab
/dev/vdb       /var/lib/rancher/k3s/storage            ext4    defaults        0 2
```

Reload fstab `sudo mount -a`

- you will need to provision each of them like this
```
# For master
k3sup install --ip 192.168.10.20 --user ubuntu --ssh-key /Users/sylflo/.ssh/server_rsa --k3s-extra-args '--no-deploy traefik --flannel-backend=none --cluster-cidr=192.168.11.0/24'

# For nodes
k3sup join --ip 192.168.10.30 --server-ip 192.168.10.20 --user ubuntu --ssh-key /Users/sylflo/.ssh/server_rsa
k3sup join --ip 192.168.10.31 --server-ip 192.168.10.20 --user ubuntu --ssh-key /Users/sylflo/.ssh/server_rsa
```

- You will also need to increase the qcow2 disk (you need to shutdown the machine first)
```
qemu-img resize ubuntu-master-1.qcow2 +10G
qemu-img resize ubuntu-worker-1.qcow2 +10G
qemu-img resize ubuntu-worker-2.qcow2 +10G
```

### Provision cluster

#### Secrets

This project is used to create secret https://github.com/bitnami-labs/sealed-secrets so they can be pushed
in the git repository


#### Cert-manager

Once cert-manager is provisionned, it is necessary to import the certificate to other namespace
```
kubectl get secret ***REMOVED***  -n cert-manager --export -o yaml | \
kubectl apply -n seedbox -f -
```


#### Nginx ingress

After cert-manager and metalLB are provisionned, install nginx ingress using helm3

`helm install my-release ingress-nginx/ingress-nginx `

