# NetPlan 网卡设定

### 1.概述

```2
	ubuntu 22.04 版本的网卡配置与 ubuntu 18系类是不同的， 其实最终还是使用NetworkManager 和 System-networkd 完成网络配置，只不过配置方式改为更直观的yaml。
ubuntu的网
```

-------

### 2.网卡设定路径

```
/etc/netplan/01-xxxx.yaml
```

-------

### 3.配置格式

#### 		3.1静态ip设定

```
network:
  ethernets:
      eno1:
          dhcp4: no
          addresses:
            - 192.168.0.6/24
          routes :
            - to: default
              via: 192.168.0.1
          nameservers:
              addresses: 
                  - 114.114.114.114
                  - 8.8.8.8
  version: 2
```

#### 		3.2动态ip设定

```
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
```

#### 		3.3网桥设定

```
network:
  ethernets:
    eno1:
      dhcp4: false
      dhcp6: false
  # add configuration for bridge interface
  bridges:
    br0:
      interfaces: [eno1]
      dhcp4: false
      addresses: [192.168.0.6/24]
      macaddress: 84:2b:2b:fa:cb:ce
      routes:
        - to: default
          via: 192.168.0.1
          #  metric: 100
      nameservers:
        addresses: [114.114.114.114,8.8.8.8]
      parameters:
        stp: false
      dhcp6: false
  version: 2
```

------

### 4.常用命令

#### 		4.1配置检查

```bash
 netplan get
```

#### 		4.2配置应用

```
 netplan apply
```

