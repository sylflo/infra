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

### VPN (WireGuard)

Once the vpn vm is created, use the ansible playbook in wireguard folder to install WireGuard.

Create a main.yaml for example

```yaml
- name: Call playbook to install wireguard
  import_playbook: install_wireguard.yaml
  vars:
    wireguard_port: "4242"
    server_ip_address: "192.168.20.21/24"
    client_ip_address: "192.168.20.22/32"
    hypervisor_ip_address: "XX.XX.XX.XX"
```

And launch this command to install WireGuard with a config for the server and client

```bash
cd wireguard/
ansible-playbook  -i ../inventory ./main.yaml 
```

### NFS

Decrypt luks disk which is used by the NFS server

```
sudo cryptsetup luksOpen /dev/md0 md0vg
```

Mount the volumes

```
sudo mount  /dev/mapper/md0vg-seedbox--config /mnt/seedbox-config/
sudo mount  /dev/mapper/md0vg-seedbox--data /mnt/seedbox-data/
```

Launch the Ansible playbook to install a NFS server and link it with the volumes previously mounted

```
cd ansible/nfs/ 
ansible-playbook -K -i ../inventory ./main.yaml    
```

### Kubernetes

#### Prepare cluster

Once the vm are created:

- you will need to provision each of them like this
```
# For master
k3sup install --ip 192.168.10.20 --user ubuntu --ssh-key /Users/sylflo/.ssh/server_rsa --k3s-extra-args '--no-deploy traefik --no-deploy servicelb --flannel-backend=none --cluster-cidr=192.168.11.0/24'

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
kubectl -n cert-manager get -o yaml secret your-domain-name-cert | \
kubectl apply -n seedbox -f -
```


#### Nginx ingress

After cert-manager and metalLB are provisionned, install nginx ingress using helm3

```
kubens default
helm install nginx ingress-nginx/ingress-nginx
```

You need to edit the default namespace to add a label for network policy
```
kubectl edit ns default 
```

And add the label like so
```
metadata:
  creationTimestamp: ""
  labels:
    app.kubernetes.io/name: default
  name: default
```

#### Velero

Once the whole cluster is provisionned, launch this command to create a cron backup for velero
```
velero schedule create whole-cluster-monthly --schedule "0 0 1 * *" 
```

#### Monitoring

Create a namespace and install prometheus with grafana using helm
```
kubectl create namespace monitoring
kubens monitoring
helm install monitoring stable/prometheus-operator
```


#### Tips

See here for best practices about k8s cluster
