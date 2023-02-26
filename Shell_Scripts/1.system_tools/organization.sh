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


#----Function-----------------------------------------------------------------------------------------------------------------------------
#  Usage: Determine the system model, the related functions of ubuntu may be written in the future. At present, only Centos7 is considered
#-----------------------------------------------------------------------------------------------------------------------------------------

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
yum -y install ntp >/dev/null 2>&1
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
base_software="unzip unrar wget tree nmap nc lrzsz screen iftop iotop htop inxi dos2unix iptables iptables-services iptables-devel iptables-utils nload psmisc vim netstat  rsync net-tools fail2ban glances tmux ifstat  "
yum -y groupinstall  "Compatibility libraries" "Debugging Tools" "Development tools"  && yum -y install epel-release && yum makecache &&  yum -y install  ${base_software}
yum -y update --exclude=kernel*

maxProcessesLimit 
Kernel_Tuning
sshOptimize
# systemctl stop NetworkManager >/dev/null 2>&1
# if [ $? -ne 0  ];then
# 	 echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): NetworkManager Change failed \n"
# fi
# systemctl disable NetworkManager >/dev/null 2>&1
# if [ $? -ne 0  ];then
#          echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): NetworkManager Change failed \n"
# fi

# systemctl enable iptables	>/dev/null 2>&1
# if [ $? -ne 0  ];then
#          echo -e "\n$(date "+${info_sign3}[%Y-%m-%d %H:%M:%S]"): Iptables  Change failed \n"
# fi
# kernel_upgrade1 
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

#-----Function---------------------
#  Usage : Sudo user initialization
#----------------------------------


show_yum_history(){
yum history
}


#----Exend_Function--------------------------------
#  Usage :  upgrade the kernel and BBR acceleration
#--------------------------------------------------
kernel_upgrade1(){
read -p "$(date "+${info_sign2}[%Y-%m-%d %H:%M:%S]"): Optional expansion :::  Upgrade the kernel ::: If required, enter Yes ，Upgrading the kernel is risky. Think twice before you act ！！！(yes|no) "  choice03
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
kernel_version="6.0.6-1.el7"
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
