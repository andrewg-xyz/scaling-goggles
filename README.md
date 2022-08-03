# scaling-goggles

Home servers deployment of a k3s cluster (see [scripts/k3s.sh](scripts/k3s.sh)). 

## Zarf

Using [zarf.dev](zarf.dev). Big Bang not included, when ready see [example](https://github.com/defenseunicorns/zarf/blob/master/packages/big-bang-core/zarf.yaml)

## Proxmox

Using proxmox with ubuntu template VMs for the cluster nodes. 

### x86-64-v2

[ref#CPU Section](https://www.talos.dev/v1.1/talos-guides/install/virtualized-platforms/proxmox/)

In proxmox the default CPU type "kvm64" will not work for v86-64-v2 (only v1). To rectify either edit or create the VM, select CPU type of `host` (which will disable live migration)
