# qemu-img 磁盘创建工具

-------

## 概述

​	qemu-img 是kvm虚拟机创建的必用软件，主要作用是 为即将部署的虚拟机准备磁盘介质。

## 命令格式以及常用命令

```
qemu-img    指令    [指令参数]
```

### 	a.介质检查

```
qemu-img  info  image_file
qemu-img check image_file

# 关于介质类型的简述：
	- raw不支持快照，只有qcow2支持快照
	- qcow2不支持重设大小，raw支持resize 
```

### 	b.创建介质

```
# qemu-img create -f <fmt> -o <options> <fname> <size>
#  -f  指定介质类型 ；raw  或 qcow2 ,默认是raw。
# -o  其他选项；-o size=4G  

eg:
qemu-img create -f raw -o size=4G /images_path/vm2.raw
qemu-img create -f qcow2 -o size=100G /images_path/vm2.qcow2
```

### 	c.基于后备镜像创建差量镜像

```
# qemu-img create -f qcow2 -b /data/kvm/vm_disks/template_machines.raw /data/kvm/vm_disks/virt_machines_01.qcow2
# 此步的核心在于  -b 参数
#  注：前端镜像是不能删除，否则后后端镜像就就无法启动
#  注：一般用于快速创建虚拟机
```

### 	d.介质类型转换

```

qemu-img convert -c -f <转换前的类型> -O <转换后的类型> -o options fname out_fname
#  此步核心在于 convert 选项 

-c：采用压缩，只有qcow和qcow2才支持
-f：源镜像的格式，它会自动检测，所以省略之
-O：目标镜像的格式


#将名为image.img的原始图像文件转换为qcow2文件。
qemu-img convert -f raw -O qcow2 image.img image.qcow2
#将vmdk文件转换raw文件。
qemu-img convert -f vmdk -O raw image.vmdk image.img
#将vmdk文件转换qcow2文件。
qemu-img convert -f vmdk -O qcow2 image.vmdk image.qcow2
```

### 	e.快照

```
qemu-img snapshot test1.qcow2 -c s1   #创建快照s1
qemu-img snapshot test1.qcow2 -l      #快照查看，使用-l参数
qemu-img snapshot test1.qcow2 -d s1   #删除快照，使用-d参数
qemu-img snapshot test1.qcow2 -a s1   #还原快照，使用-a参数

#快照单独提取镜像，可以使用convert参数
qemu-img convert -f qcow2 -O qcow2 -s s1 test1.qcow2    test-s1.qcow2  
```

### 	f.对raw类型介质的resize

```
# qemu-img resize filename [+ | -]size
qemu-img resize test1.raw +2G
```

