# SUDO管理

#### 配置文件

```sh
# 建议使用 visudo 修改sudo文件，此命令可以检查配置文件语法。(sudo配置文件错误可能产生灾难)

# sudo 条目语法
      who  	  which_hosts=(runer)   [TAG:] commad  		   			# 命令必须为绝对路径,命令前TAG定义命令属性，例如NOPASSWD、PASSWD，TAG可忽略。
eg : huken   ALL=(root)                NOPASSWD: /usr/sbin/cat   # 允许huken以root的身份，免密运行 cat 命令

# 别名分组  
别名分组需要全部使用大写英文字母,必须先定义后引用

- 用户别名   #指定一个用户组，sudo中称  ' 别名 ' 
User_Ailas  <用户别名> = <用户名>, <%用户组名>
User_Ailas  HUKEN_MANAGER = huken, sremanager,  %root
...

-身份别名 # Runas_Alias    这个别名指定的是“用户身份”，即sudo允许切换的用户身份
Runas_Alias  <身份别名> = <用户名>
Runas_Alias  ADMIN = root

- 命令别名
Cmnd_Alias  <命令别名> = <命令绝对路径>, <命令绝对路径>
Cmnd_Alias  HUKEN_COMMAND = /usr/sbin/useradd, /usr/sbin/userdel, /usr/sbin/nginx
----

# 调用
HUKEN_MANAGER         ALL=(ADMIN)    NOPASSWD:  HUKEN_COMMAND

```

#### 命令

```sh
sudo   -l   列出当前用户可用的sudo命令
sudo   -s  切换到root用户
sudo   -u   <user>  <commad>  # 指定用户执行命令
```

#### 实例

```shell
cat   /etc/sudoers.d/permissions
--------
    ### Networking
    Cmnd_Alias NOPASS_NETWORKING = /sbin/route, /sbin/ifconfig, /sbin/ip, /bin/ping, /bin/ping6, /bin/traceroute, /sbin/dhclient, /usr/bin/net, /sbin/iptables, /usr/bin/rfcomm, /usr/bin/wvdial, /sbin/iwconfig, /sbin/mii-tool, /usr/bin/host, /usr/bin/nslookup, /bin/hostname, /bin/hostnamectl
    Cmnd_Alias PASS_NETWORKING = /sbin/ifconfig del, /sbin/ip del, /sbin/ifup, /sbin/ifdown, /usr/sbin/brctl

    ### Installation and management of software
    Cmnd_Alias NOPASS_SOFTWARE = /bin/rpm, /usr/bin/up2date, /usr/bin/yum, /usr/bin/make, /usr/bin/cmake, /usr/bin/ccmake, /usr/bin/pip, /usr/bin/easy_install

    ### Services
    Cmnd_Alias NOPASS_SERVICES = /sbin/service, /sbin/chkconfig, /etc/init.d/*, /usr/bin/systemctl start, /usr/bin/systemctl stop, /usr/bin/systemctl reload, /usr/bin/systemctl restart, /usr/bin/systemctl status, /usr/bin/systemctl enable, /usr/bin/systemctl disable, /usr/bin/nohup, /bin/journalctl

    ### Updating the locate database
    Cmnd_Alias NOPASS_LOCATE = /usr/bin/updatedb

    ### Storage
    Cmnd_Alias NOPASS_STORAGE = /sbin/fdisk, /sbin/sfdisk, /sbin/parted, /sbin/partprobe, /bin/mount, /bin/umount
    Cmnd_Alias PASS_FORMATTING = /sbin/mkfs, /sbin/mkfs.btrfs, /sbin/mkfs.cramfs, /sbin/mkfs.ext2, /sbin/mkfs.ext3, /sbin/mkfs.ext4, /sbin/mkfs.minix, /sbin/mkfs.xfs

    ### Delegating permissions
    Cmnd_Alias NOPASS_DELEGATING = /bin/chown, /bin/chmod, /bin/chgrp, !/usr/sbin/visudo, !/usr/bin/vi *sudoer*, !/usr/bin/vim *sudoer*, /usr/bin/echo *sudoer*

    ### Processes
    Cmnd_Alias PASS_PROCESSES = /bin/nice, /bin/kill, /usr/bin/kill, /usr/bin/killall, /usr/bin/pkill

    ### System Information
    Cmnd_Alias NOPASS_SYSTEM_INFORMATION = /bin/uname, /bin/hostname, /usr/bin/lscpu, /usr/bin/free, /usr/sbin/iftop, /usr/sbin/iotop, /usr/bin/ionice, /usr/bin/sar, /bin/netstat, /usr/sbin/ss, /usr/bin/top, /bin/ps, /usr/bin/pstree, /bin/df, /usr/bin/iostat, /usr/bin/vmstat, /usr/bin/inxi, /usr/bin/uptime, /usr/bin/du, /usr/sbin/lsof

    ### Text 
    Cmnd_Alias NOPASS_TEXT = /bin/grep, /bin/awk, /bin/find, /usr/bin/locate, /bin/cat, /bin/tac, /usr/bin/head, /bin/more, /usr/bin/less, /usr/bin/tail, /usr/bin/tailf, /bin/cut, /bin/egrep, /bin/fgrep, /usr/bin/rename, /bin/sort, /usr/bin/tr, /usr/bin/uniq, /usr/bin/wc, /usr/bin/whatis, /usr/bin/whereis, /usr/bin/which, /bin/touch, /bin/mkdir, /usr/bin/install, /bin/ln, /bin/cp, /bin/mv, /usr/bin/dos2unix, /usr/bin/watch, /usr/bin/xargs

    ### Text modify
    Cmnd_Alias NOPASS_TEXT_MODIFY = /bin/vi, /usr/bin/vim, /bin/rm, /bin/echo, /bin/sed

    ### Compression
    Cmnd_Alias NOPASS_COMPRESSION = /bin/tar, /bin/gzip, /bin/gunzip, /usr/bin/zip, /usr/bin/unzip, /usr/bin/bzip2, /usr/bin/zdiff, /usr/bin/zgrep, /usr/bin/zegrep, /usr/bin/zfgrep, /usr/bin/zipgrep, /usr/bin/zless, /usr/bin/zmore, /usr/bin/xz, /usr/bin/unxz, /usr/bin/xzcat, /usr/bin/xzcmp, /usr/bin/xzdec, /usr/bin/xzdiff, /usr/bin/xzegrep, /usr/bin/xzfgrep, /usr/bin/xzgrep, /usr/bin/xzless, /usr/bin/xzmore, /usr/bin/bzcat, /usr/bin/bzcmp ,/usr/bin/bzdiff, /usr/bin/bzgrep, /usr/bin/bzip2, /usr/bin/bzless, /usr/bin/bzmore

    ### File push
    Cmnd_Alias NOPASS_FILEPUSH = /usr/bin/rz, /usr/bin/sz, /usr/bin/scp, /usr/bin/rsync

    ### Create user and group
    Cmnd_Alias NOPASS_CREATE_USER = /usr/sbin/useradd, ! /usr/bin/passwd root, /usr/bin/passwd, /usr/sbin/userdel, /usr/sbin/groupadd, /usr/sbin/groupdel, /usr/bin/chage, /bin/chgrp, /usr/sbin/chpasswd, /usr/bin/gpasswd ,/usr/sbin/groupmod, /usr/bin/id

    ### Time
    Cmnd_Alias NOPASS_TIME = /sbin/clock, /usr/sbin/clockdiff, /bin/date, /sbin/hwclock, /usr/sbin/ntpdate

    ### Crontab
    Cmnd_Alias NOPASS_CRONTAB = /usr/bin/crontab

    ### Diff
    Cmnd_Alias NOPASS_DIFF = /usr/bin/diff, /usr/bin/vimdiff

    ### SHELL
    Cmnd_Alias NOPASS_SHELL = /bin/bash, /bin/sh, /bin/usleep, /bin/sleep

    ### Security
    Cmnd_Alias NOPASS_SECURITY = /sbin/ip6tables, /sbin/iptables, /sbin/iptunnel, /usr/sbin/setenforce, /usr/sbin/getenforce

    ### Capture package
    Cmnd_Alias NOPASS_CAPTURE = /usr/sbin/tcpdump, /usr/sbin/tshark

    ### Audit
    Cmnd_Alias NOPASS_AUDIT = /usr/bin/last, /usr/bin/lastlog, /usr/bin/who, /usr/bin/whoami

    ### Command
    Cmnd_Alias NOPASS_COMMAND = /usr/bin/virsh, /usr/bin/virt-install, /usr/sbin/qemu-kvm, /usr/bin/qemu-img

    ### Other
    Cmnd_Alias NOPASS_OTHER = /usr/bin/screen, /usr/bin/wget, /usr/bin/nc, /usr/bin/nmap, /usr/bin/curl

    ## Allow root to run any commands anywhere 
    sremanager	ALL=(ALL)	NOPASSWD: NOPASS_NETWORKING, NOPASS_SOFTWARE, NOPASS_SERVICES, NOPASS_LOCATE, NOPASS_STORAGE, NOPASS_DELEGATING, NOPASS_SYSTEM_INFORMATION, NOPASS_TEXT, NOPASS_TEXT_MODIFY, NOPASS_COMPRESSION, NOPASS_FILEPUSH, NOPASS_CREATE_USER, NOPASS_TIME, NOPASS_SECURITY, NOPASS_CAPTURE, NOPASS_AUDIT, NOPASS_CRONTAB, NOPASS_DIFF, NOPASS_SHELL, NOPASS_COMMAND, NOPASS_OTHER, PASSWD: PASS_NETWORKING, PASS_FORMATTING, PASS_PROCESSES

    Defaults:sremanager timestamp_timeout=5

    developer	ALL=(ALL)	NOPASSWD: NOPASS_SYSTEM_INFORMATION, NOPASS_TEXT, NOPASS_COMPRESSION, NOPASS_FILEPUSH, NOPASS_DIFF
```



#### 附录

```sh
- Host_Ailas  主机别名  # 一般用不上，故忽略。
❏在生产场景中，一般不需要设置主机别名，在定义授权规则时可以通过ALL来匹配所有的主机。
❏请注意上面定义的规范，有些规范虽然不是必需的，但最好能够按照系统的标准来进行配置，这样可以避免意外问题的发生。
❏其实，主机名就是一个逻辑上的主机组，当多台服务器共享一个/etc/sudoers的时候就会用到这个主机别名。不过，在实际企业运维中，这个需求几乎是不存在的。
```

