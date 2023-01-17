# 几个安装案例，以供参考

```
 virt-install --name=00-master \
 --vcpus=4 --memory=6144 --disk=/data/kvm_machines/vm_disks/00-master.qcow2 \
 --cdrom=/data/iso_image/CentOS-7-x86_64-Minimal-1810.iso \
 --noautoconsole --autostart \
 --network bridge=br0 \
 --graphics vnc,listen=0.0.0.0,port=5960

  virt-install --name=01-slave \
 --vcpus=2 --memory=4096 --disk=/data/kvm_machines/vm_disks/01-slave.qcow2 \
 --cdrom=/data/iso_image/CentOS-7-x86_64-Minimal-1810.iso \
 --noautoconsole --autostart \
 --network bridge=br0 \
 --graphics vnc,listen=0.0.0.0,port=5961

  virt-install --name=02-slave \
 --vcpus=2 --memory=4096 --disk=/data/kvm_machines/vm_disks/02-slave.qcow2 \
 --cdrom=/data/iso_image/CentOS-7-x86_64-Minimal-1810.iso \
 --noautoconsole --autostart \
 --network bridge=br0 \
 --graphics vnc,listen=0.0.0.0,port=5962

   virt-install --name=03-slave \
 --vcpus=2 --memory=4096 --disk=/data/kvm_machines/vm_disks/03-slave.qcow2 \
 --cdrom=/data/iso_image/CentOS-7-x86_64-Minimal-1810.iso \
 --noautoconsole --autostart \
 --network bridge=br0 \
 --graphics vnc,listen=0.0.0.0,port=5963
```

