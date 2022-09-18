#!/bin/env bash 
   
# Usage     : Easily organized tuning scripts
# Date      : 1949_04_24
# Auther    : Управление по защите земли при коммунистическом Интернационале
# Contact   : hukenis@163.com

# Applicable model: Centos7 & previous version


#----Function---------------------------------------------
#  Usage: Define signal identification and time stamp 
#  Example : $(date "+${info_sign<num>}[%Y-%m-%d %H:%M:%S]")
#---------------------------------------------------------
info_sign1=[INFO]
info_sign2=[WARRING]
info_sign3=[FAILED]

# time_stamp=$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]")


#----Function-----------------------------------------------------------------------------------
#  Usage: Determine the system model, User permissions ; This part belongs to the public premise
#-----------------------------------------------------------------------------------------------

judge_user(){
if [[ -z $(whoami | grep -oi root ) ]];then 
	sleep 1
	echo "$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): Non privileged users cannot use this script !!! ";exit 3
fi
}
judge_user

test_distro_arch() {
    ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    if [ "$ARCH" = 32 ]; then
	sleep 1
        echo "$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): 32-bit Arch kernel does not support"
        exit 1
    fi
}
test_distro_arch


#----Function-----------------------
#  Usage: OS Process Branch Function
#-----------------------------------
judge_os(){
avalible_os_=(centos ubuntu)
os_message=/etc/os-release
for os in ${avalible_os_}
do
	os=$(grep  -i "${os}"  ${os_message} |awk  -F "="  '/^NAME/{print $2}')
	version=$(grep -i "^version" ${os_message} | awk 'NR==1{print $0}')
	if [[  -z ${os}   ]];then
		sleep 1
		echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Unspecified system, about to exit";exit
	else
		sleep 2
		echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Current system is ${os} ,  ${version}"
	fi
done

interpretation1=$(echo ${os} |sed 's/Linux//g'| grep -Ei "centos|ubuntu")
interpretation2=$(echo ${version} | awk -F "=" '{if($2~/[0-9]/)print $2}' | grep  -o [0-9])
if   echo ${interpretation1} | grep -qwi "centos";then
	if [[ ${interpretation2} -ge 7 ]];then
		sleep 1
		echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): 准备中，五秒后开始";sleep 4
		install_centos7
		# echo "$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Conforming to the standard, preparatory implementation"  ## 调用centos系列功能
	else
		sleep 1
		echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): Only supports centos7/8";exit 1
	fi
elif echo ${interpretation1} | grep -qwi "ubuntu";then
	sleep 1
	echo "Function not developed";exit	## 调用ubuntu 系列功能
fi
}


#----Function------------------------------------------------
#  Usage: Organizational transformation applicable to centos7
#------------------------------------------------------------
disableSelinux(){
local selinuxConfig='/etc/selinux/config'
local selinuxConfigBackup='/etc/selinux/config.backup'
    if [ -e $selinuxConfigBackup ];then
        sed -i 's/\(SELINUX=\)enforcing/\1disabled/g' $selinuxConfig
        (setenforce 0 &>/dev/null)&& systemctl stop firewalld ;systemctl disable firewalld
	sleep 1
	echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): The firewall has been turned off "
    else
        cp ${selinuxConfig}{,.backup}
        sed -i 's/\(SELINUX=\)enforcing/\1disabled/g' $selinuxConfig
	(setenforce 0 &>/dev/null)&& systemctl stop firewalld ;systemctl disable firewalld
	sleep 1
	echo -e  "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): The firewall has been turned off "
    fi
}

Calibration_time(){
timedatectl set-timezone Asia/Shanghai >/dev/null 2>&1
ntpdate cn.pool.ntp.org >/dev/null 2>&1
yum install ntp >/dev/null 2>&1
systemctl start ntpd >/dev/null 2>&1
systemctl enable ntpd >/dev/null 2>&1
timedatectl set-ntp yes >/dev/null 2>&1


if   [[ -n $(timedatectl | grep CST) ]]&&[[ -n $(timedatectl | grep "Asia/Shanghai") ]];then
	sleep 1
	echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Local time adjusted to China Standard Time Zone"
elif [[ -n $(timedatectl | grep "NTP enabled: yes") ]];then
	sleep 1
	echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Success to enable ntp time synchronization"
else
	sleep 1
	echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Failed to enable time synchronization"
fi
}


#----Function---------------------------------------------
#  Notice : Look here, here is the main function of Centos
#---------------------------------------------------------
install_centos7(){
disableSelinux
Calibration_time
useradd_

mkdir /opt/{scripts,tools,source_package} -p
mkdir /data  -p
# Network environment check
if   [[ -z  $(grep -E "8.8.8.8|114.114.114.114" /etc/resolv.conf)  ]];then
	sed -i '$a\nameserver 8.8.8.8'          /etc/resolv.conf
	sed -i '$a\nameserver 114.114.114.114'  /etc/resolv.conf
elif [[ -z $(ip a | awk '/inet/{print $2}' | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}') ]];then
	sleep 1
	echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): No ipv4 address is detected"
elif [[ -z $(curl -Is www.baidu.com  | grep -o OK) ]] &&  [[ -z $(curl -Is --connect-timeout 10 -m 20 https://github.com/ | grep -o OK) ]];then
	sleep 1 
	echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): Unable to access the Internet,The yum instruction may not execute normally";exit 1
fi

# Basic software deployment
sleep 1
echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Deploy basic software and development tools ";sleep 2
base_software="yum-plugin-fastestmirror unzip unrar  yum-axelget wget tree nmap nc lrzsz screen iftop iotop htop inxi dos2unix iptables iptables-services iptables-devel iptables-utils nload psmisc vim netstat  rsync net-tools fail2ban glances tmux ifstat  "
yum -y groupinstall  "Compatibility libraries" "Debugging Tools" "Development tools"  && yum -y install epel-release && yum makecache &&  yum -y install  ${base_software}
yum -y update --exclude=kernel*

maxProcessesLimit 
Kernel_Tuning
sshOptimize
systemctl stop NetworkManager >/dev/null 2>&1
if [ $? -ne 0  ];then
	 echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): NetworkManager Change failed \n"
fi
systemctl disable NetworkManager >/dev/null 2>&1
if [ $? -ne 0  ];then
         echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): NetworkManager Change failed \n"
fi

systemctl enable iptables	>/dev/null 2>&1
if [ $? -ne 0  ];then
         echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): Iptables  Change failed \n"
else
	(iptables_init && echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Iptables Initialization completed \n" )
fi
kernel_upgrade1 
}


#----Function-----------------
#  Usage : Optimize the kernel
#-----------------------------
Kernel_Tuning(){
local sysctlConfig='/etc/sysctl.conf'
local sysctlConfigBackup='/etc/sysctl.conf.backup'
    if [ -e $sysctlConfig ];then
	Tuning_parameters
	sleep 1
        echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Kernel tuning completed \n"
    else
        cp ${selinuxConfig}{,.backup}
	Tuning_parameters
	sleep 1
        echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): Kernel tuning completed \n"
    fi
}

maxProcessesLimit(){
local limitsConfig='/etc/security/limits.conf'
local limitsConfigBackup='/etc/security/limits.conf.backup'
local userLimitsConfigBackup='/etc/security/limits.d/20-nproc.conf'
local userLimitsConfig='/etc/security/limits.d/20-nproc.conf.backup'
    if [ -e $limitsConfigBackup ];then
        if [ `grep "*               -       nproc          65535" $limitsConfig |wc -l` -eq 0 ];then
	    echo '*               -       nproc          65535 ' >>$limitsConfig
        fi
    else
        cp ${limitsConfig}{,.backup}
        if [ `grep "*               -       nproc          65535" $limitsConfig |wc -l` -eq 0 ];then
            echo '*               -       nproc          65535 ' >>$limitsConfig
        fi
    fi

    if [ -e ${userLimitsConfigBackup} ];then
	sed -i 's#*          soft    nproc     4096#*          soft    nproc     unlimited#g' ${userLimitsConfig}
    else
	cp ${userLimitsConfig}{,.backup}
	sed -i 's#*          soft    nproc     1024#*          soft    nproc     unlimited#g' ${userLimitsConfig}
    fi
}

Tuning_parameters(){
cat >> /etc/sysctl.conf << EOF
#CTCDN系统优化参数
#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
#决定检查过期多久邻居条目
net.ipv4.neigh.default.gc_stale_time=120
#使用arp_announce / arp_ignore解决ARP映射问题
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.lo.arp_announce=2
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
#开启路由转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.default.send_redirects = 1
#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
#关闭sysrq功能
kernel.sysrq = 0
#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144
#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800
#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1
#启用timewait 快速回收
#net.ipv4.tcp_tw_recycle = 0
#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000
#修改防火墙表大小，默认65536
net.netfilter.nf_conntrack_max=655350
net.netfilter.nf_conntrack_tcp_timeout_established=1200
# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
EOF
/sbin/sysctl -p >/dev/null 2>&1
}

#----Function-----------
#  Usage : Optimize SSH
#-----------------------
sshOptimize(){
local sshConfig='/etc/ssh/sshd_config'
local sshConfigBackup='/etc/ssh/sshd_config.backup'
if [ -e $sshConfigBackup ];then
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' $sshConfig	## 禁止空密码登入
    sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' $sshConfig	## 优化ssh登入速度
    sed -i 's/^#UseDNS yes/UseDNS no/g' $sshConfig	## 优化ssh登入速度
    /etc/init.d/sshd reload >/dev/null 2>&1  	## 重载ssh配置
    sleep 1 
    echo -e  "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): SSH optimization completed \n"   
else
    cp ${sshConfig}{,.backup}
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' $sshConfig
    sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' $sshConfig
    sed -i 's/^#UseDNS yes/UseDNS no/g' $sshConfig
    /etc/init.d/sshd reload >/dev/null 2>&1
    sleep 1
    echo -e  "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): SSH optimization completed \n"   
fi
}

#-----Function--------------------
#  Usage : Iptables initialization
#---------------------------------
iptables_init(){
local iptables_config="/etc/sysconfig/iptables-config"
local iptables_config_Backup='/etc/sysconfig/iptables-config.backup'
if [ -e $sshConfigBackup ];then
	Initialize_import	
else
	cp ${iptables_config}{,.backup}
	Initialize_import 
	if systemctl start iptables;then
		echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): iptables is started"
	else
		echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"):  Failed to start iptables"
	fi
fi
}

Initialize_import(){
cat <<EOF >/etc/sysconfig/iptables-config

    # clear all earlier configurations
    iptables -F
    iptables -t nat -F
    iptables -t mangle -F
    iptables -X
    iptables -t nat -X
    iptables -t mangle -X

    iptables -P INPUT DROP
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT DROP

    # enable loopback
    iptables -A INPUT -i lo -j ACCEPT

    # enable already established connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED,UNTRACKED -j ACCEPT

    # enable all outbound traffic
    iptables -A OUTPUT -j ACCEPT
    
    # enable ssh
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp --dport 62815 -j ACCEPT

    # enable HTTP and HTTPS
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    iptables -A INPUT -p tcp --dport 7676 -j ACCEPT
    iptables -A INPUT -p tcp --dport 7677 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8888 -j ACCEPT

    # enable dns
    iptables -A INPUT -p tcp --dport 53 -j ACCEPT
    iptables -A INPUT -p udp --dport 53 -j ACCEPT

    # enable Common software
    iptables -A INPUT -p tcp --dport 25 -j ACCEPT
    iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
    iptables -A INPUT -p tcp --dport 3389 -j ACCEPT
    iptables -A INPUT -p tcp --dport 6379 -j ACCEPT
    iptables -A INPUT -p tcp --dport 9092 -j ACCEPT
    iptables -A INPUT -p tcp --dport 10050 -j ACCEPT
    iptables -A INPUT -p tcp --dport 10051 -j ACCEPT
    iptables -A INPUT -p tcp --dport 23000 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22122 -j ACCEPT

    # enable ping
    iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

    # enable mail
    iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 992 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT

EOF
}

#-----Function---------------------
#  Usage : Sudo user initialization
#----------------------------------
useradd_(){
(useradd sremanager&& useradd developer) >/dev/null 2>&1
passwd1=`< /dev/urandom tr -dc A-Za-z0-9 | head -c 20; echo` 
passwd2=`< /dev/urandom tr -dc A-Za-z0-9 | head -c 20; echo`
echo $passwd1 | passwd sremanager --stdin  >/dev/null 2>&1
echo $passwd2 | passwd developer  --stdin  >/dev/null 2>&1
sleep 2
echo -e  "$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]") : Two users have been added. The account secret is as follows:\nsremanager/$passwd1 \ndeveloper/$passwd2 " |tee /root/user_info.log; for i in `seq 1 2`;do unset passwd$i;done  # 安全步骤-撤销密码的赋值
sleep 2
echo -e  "$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]") : Saved in \"/root/user_info.log\" , Sudo entitlement completed ; Sremanager is adminer , Developer is Ordinary users "
Distribution_of_power
}


Distribution_of_power(){
cat <<EOF >/etc/sudoers.d/permissions
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

EOF
}

#----Exend_Function--------------------------------
#  Usage :  upgrade the kernel and BBR acceleration
#--------------------------------------------------
kernel_upgrade1(){
read -p "$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Optional expansion :::  Upgrade the kernel ::: If required, enter Yes ，Upgrading the kernel is risky. Think twice before you 
act ！！！(yes|no) "  choice03
case $choice03 in
        yes|YES|y|Y)
        kernel_upgrade
        ;;
        no|NO|n|N)
        exit 0
        ;;

esac
}

kernel_upgrade(){
kernel_version="5.19.9-1.el7"
kernel_name="kernel-ml-${kernel_version}.elrepo.x86_64.rpm"
kernel_devel_name="kernel-ml-devel-${kernel_version}.elrepo.x86_64.rpm"
# curl -o /opt/tools/${kernel_name}  https://elrepo.org/linux/kernel/el7/x86_64/RPMS/${kernel_name}
# curl -o /opt/tools/${kernel_name}  https://elrepo.org/linux/kernel/el7/x86_64/RPMS/${kernel_devel_name}
if [[ -z $(find / -name "${kernel_name}") ]]&&[[ -z $(find / -name "${kernel_devel_name}") ]];then
	echo -e "\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): KERNEL DOWNLOADING ...\n$(date "+${info_sign1}[%Y-%m-%d %H:%M:%S]"): KERNEL_DEVEL DOWNLOADING ...";sleep 2
	download_kernel
	download_devel
	
fi

install_kernel&&BBR_speedup
Restart_required
}

download_kernel(){
curl -o /opt/tools/${kernel_name}  https://elrepo.org/linux/kernel/el7/x86_64/RPMS/${kernel_name}
if [  $? -ne  0 ];then
retry_download_kernel
fi
}

download_devel(){
curl -o /opt/tools/${kernel_devel_name}  https://elrepo.org/linux/kernel/el7/x86_64/RPMS/${kernel_name}
if [  $? -ne  0 ];then
retry_download_devel
fi
}

retry_download_kernel(){
read -p  "$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"):下载失败，是否重试？（Y|N）" choice01
        case $choice01 in
        Y|y|yes|Yes)
        sleep 3
        download_kernel
	;;
	N|n|no|No)
	sleep 1
	echo "bye ~";exit 2 
	;;
        esac
}

retry_download_devel(){
read -p  "$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"):下载失败，是否重试？（Y|N）" choice02
        case $choice02 in
        Y|y|yes|Yes)
        sleep 3
        download_kernel
	;;
        N|n|no|No)
        sleep 1
        echo "bye ~";exit 2
	;;
        esac
}

install_kernel(){
cd /opt/tools/ && yum -y localinstall kernel-ml-*
if [ $? -ne 0  ];then
	sleep 1
	echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): Kernel upgrade failed!!!"&& exit 3 
else
#old_kernel=$(grub2-editenv list|awk -F "=" '{print $2}')
#old_kernel=$(grub2-editenv list|awk -F "=" '{print $2}')
#new_kernel=$(awk -F \' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg | awk -F ":" '/${kernel_version}/{print $2}')
#new_kernel=$(awk -F \' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg | awk -F ":" '/${kernel_version}/{print $2}')
grub2-set-default 0
#	if	[[ -z $(grub2-editenv list |grep ${new_kernel})  ]];then
#		sleep 1 
#		echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Kernel boot order changed "
#	else
#		grub2-set-default \'${old_kernel}\'
#		sleep 1
#		echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): The kernel boot order could not be changed,and the default has been rolled back !!!";exit 3
#	fi
fi


}

Restart_required(){
shutdown -r +2  "$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): During the kernel update, the system will restart in 2 minutes. Save your work progress as soon as possible!! If the system function is abnormal after restart, please recover and switch to the initial kernel startup"
sleep 1
echo -e "\n $(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Use >> shutdown -c << to terminate the restart !! "
monitor_shutdown&
}

monitor_shutdown(){
shutdown_pid=$(ps -ef| grep shutdown | grep -v grep| awk '{print $2}' )
if [[ -z ${shutdown_pid}  ]];then
        echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Restart has been terminated"| tee ;exit 3
fi
while  monitor_shutdown
do
monitor_shutdown& 
sleep 2
done 
}

BBR_speedup(){
cat << EOF >> /etc/sysctl.conf
	net.core.default_qdisc = fq
	net.ipv4.tcp_congestion_control = bbr
EOF
sudo sysctl -p  >/dev/null/ 2>&1
if [[ -n $(sysctl net.ipv4.tcp_available_congestion_control| grep -io bbr)  ]]&& [[ -n $(lsmod | grep bbr)  ]];then
	sleep 1
	echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): BBR acceleration is enabled "
else
	echo -e "\n$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): BBR acceleration start failed and configuration rolled back "
	sed -i '/net.core.default_qdisc = fq/d'  	   /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control = bbr/d'  /etc/sysctl.conf
fi
}


#----Function-------------------
#  Notice : Protagonist function 
#-------------------------------

Main(){
judge_os
}

Main


#-----Analysis_01------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Annotation : 总体的结构还是由多个功能，按照不同分工进行嵌套，缩减调用时多余的代码量；最后使用一个总的函数作为入口，调度总体；（shell的执行顺序是先读后执行，如果提前调用了函数，而此部分函数尚未读取到，那么就会出现不识别的功能报错）；比较稳的方式，还是功能块随便写，把总的开关放在后面。judge_os ==> install_centos ==> _function ;这样函数块的读取顺序就不会成为执行的阻力，虽然看起来乱了一些；如果后续再添加一个支杆，只要写好对应的函数块并集合到其下，写好总开关的触发即可，也就说最后把支杆做到 judge_os 下 即可实现拓展！
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#----Analysis_02----------------------------------------------------------------------------------------------------------------------------
# supplement : Main（唯一执行入口） ==> judge_os (分支选择) ==> install_centos/install_ubuntu {Function1,Function2..} (分支路线及其功能集合)
#-------------------------------------------------------------------------------------------------------------------------------------------
