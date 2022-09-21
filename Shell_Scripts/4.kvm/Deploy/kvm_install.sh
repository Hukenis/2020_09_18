#!/bin/env bash 
# Date ： 2022年9月21日19:31:54
# Usage ： 快速创建kvm环境.

os_name=`cat /etc/redhat-release  | awk '{print $1}'`
os_release=`cat /etc/redhat-release  | awk -F "release" '{print $2}' | awk -F "." '{print $1}'`
kenel_release01=`uname -r  | cut -d "." -f 1`
kenel_release02=`uname -r`
kvm_suport_virual_env=`lscpu | grep Virtualization: | awk '{print $2}'`
kvm_suport_modules_env=`lsmod | grep kvm`
kvm_suport_net_env=`yum -y list net-tools | grep Installed -2 | awk 'NR>1{print $1}'`
kvm_suport_netbridge_env01=`yum -y list bridge-utils | grep Installed -2 | awk 'NR>1{print $1}'`
kvm_suport_qemu_env=`yum -y list qemu-kvm  | grep Installed -2 | awk 'NR>1{print $1}'`
kvm_suport_libvirt_env=`yum -y list libvirt virt-install  | grep Installed -2 | awk 'NR>1{print $1}'`
kvm_suport_libvirt_status=`systemctl status libvirtd | grep running|awk -F " " '{print $3}' | cut -c 2-8`
kvm_suport_netbridge_env02=`ls /etc/sysconfig/network-scripts/ | grep br | awk -F "-" '{print $2}'`
kvm_suport_netbridge_env03=`ip a | grep ${kvm_suport_netbridge_env02} | grep inet  | awk '{print $2}' |awk -F "/" '{print $1}'`
kvm_suport_netbridge_env04=`for i in ${kvm_suport_netbridge_env03};do ping -c 100 -f  $i|awk 'NR==4 {print $0}'| awk '{print $4}' ;done` 


function_system_info(){
if	[ ${os_name} !=  "CentOS" ];then
	echo -e "\n>>此脚本为Centos7代以上系统适用"&&exit 1
else
	if	[ ! ${os_release} -ge 7   ];then
		echo -e "\n>>此脚本为Centos7代以上系统适用"&&exit 1
	else
		#echo -e " \e[1;37m 当前系统版本为:\e[0m \n${os_name} ${os_release}"&&${print_sgin}
		echo -e "\n\n>>当前系统版本为:  ${os_name} ${os_release}\n"
	fi
fi
}
# echo -e "当前系统版本为: \n${os_name} ${os_release} "
# --------------------------------------------------

function_kernel_info(){
if [ ! ${kenel_release01} -ge 3 ];then
	while true;
	do
		read -p ">>内核版本太低，是否继续？" choice01
		case ${choice01} in
			y|yes|Y|YES|Yes)
				break
				;;
			n|no|NO|No|No)
				exit
				;;
			*)
				echo " Yes or No "
				;;
		esac
	done
else
	echo -e ">>当前内核版本为: ${kenel_release02} \n"
fi
}
# echo -e "当前内核版本为: \n${kenel_release02} "
# --------------------------------------------------

function_virual_info(){
if	[ -z ${kvm_suport_virual_env} ];then
	echo ">>当前CPU不支持虚拟化 \n"&& exit 1
else
	if	[[ -z ${kvm_suport_modules_env} ]];then
		echo -e ">>内核暂未开启KVM模块 \n"&& exit
	else
		echo -e ">>kvm 模块状态:\n${kvm_suport_modules_env}"
	fi
fi
}
# echo -e "是否支持虚拟化: \n${kvm_suport_virual_env} "
# echo -e "是否支持kvm模块: \n${kvm_suport_modules_env}"
#--------------------------------------------------------
function_net-tools_info(){
if	[[ -z ${kvm_suport_net_env} ]];then
	while true;
        do
                read -p ">>是否安装net-tools？" choice02
                case ${choice02} in
                        y|yes|Y|YES|Yes)
                                yum -y install net-tools
				break
                                ;;
                        n|no|NO|No|No)
                                exit
                                ;;
                        *)
                                echo " Yes or No "
                                ;;
                esac
        done
else
        echo -e ">>已安装net-tools: \n${kvm_suport_net_env} "
fi
}
# echo -e "网络工具是否安装: \n${kvm_suport_net_env}"
#----------------------------------------------------

function_netbridge_info00(){
if      [[ -z ${kvm_suport_netbridge_env01} ]];then
        while true;
        do
                read -p ">>是否安装net-tools？" choice03
                case ${choice03} in 
                        y|yes|Y|YES|Yes)
                                yum -y install bridge-utils
                                break
                                ;;
                        n|no|NO|No|No)
                                exit
                                ;;
                        *)
                                echo " Yes or No "
                                ;;
                esac
        done
else
        echo -e "\n>>已安装bridge-utils:  ${kvm_suport_netbridge_env01}\n "
fi
}
# echo -e "网桥是否安装: \n${kvm_suport_netbridge_env01}"
#-------------------------------------------------------

function_qemu_info(){
if      [[ -z ${kvm_suport_qemu_env} ]];then
        while true;
        do
                read -p ">>是否安装Qemu？" choice04
                case ${choice04} in 
                        y|yes|Y|YES|Yes)
                                yum -y install qemu-kvm.x86_64
                                break
                                ;;
                        n|no|NO|No|No)
                                exit
                                ;;
                        *)
                                echo " Yes or No "
                                ;;
                esac
        done
else
        echo -e "\n>>已安装Qemu : ${kvm_suport_qemu_env}\n"
fi
}
# echo -e "Qume环境是否安装: \n${kvm_suport_qemu_env}"
#-----------------------------------------------------

function_libvirt_info(){
if      [[ -z ${kvm_suport_libvirt_env} ]];then
        while true;
        do
                read -p ">>是否安装libvirt？" choice05
                case ${choice05} in
                        y|yes|Y|YES|Yes)
                                yum -y install libvirt.x86_64  virt-install.noarch && systemctl start libvirtd && systemctl enable  libvirtd
                                break
                                ;;
                        n|no|NO|No|No)
                                exit
                                ;;
                        *)
                                echo " Yes or No "
                                ;;
                esac
        done
else
	if	[[ ${kvm_suport_libvirt_status} -ne "running"  ]];then
		systemctl start libvirtd&& echo -e "\n Libvirt_Status : \n${kvm_suport_libvirt_status}"
		local libvirt_pid=` ps -ef| grep libvirtd | grep -v grep  | awk '{print $2}'`
		if	[[ -z ${libvirt_pid}  ]];then
			echo " libvirt 未运行 "
		fi
	else	
		echo -e "\n>>已安装Libvirt: \n ${kvm_suport_libvirt_env}"
		echo -e "\n>>Libvirt_Status: \n ${kvm_suport_libvirt_status}"
	fi

fi
}
# echo -e "Libvirt环境是否安装: \n${kvm_suport_libvirt_env}"
# echo -e "Libvirt是否启动: \n${kvm_suport_libvirt_status}"
#----------------------------------------------------------

function_netbridge_info01(){
if      [ -z ${kvm_suport_netbridge_env02} ];then
	echo -e "[请先手动配置网桥] ~ \n"&& exit 2
else
	for i in ${kvm_suport_netbridge_env04}
	do 
		if	[ $i -ne 0  ];then
			echo -e "\n>>网桥：${kvm_suport_netbridge_env02}；状态正常"
		else
			echo -e ">>网桥状态异常 \n"&& exit 1
		fi
	done
fi
}
# echo -e "网桥是否存在: \n${kvm_suport_netbridge_env02} ${kvm_suport_netbridge_env03}"


Main_Check-Env(){
function_system_info
function_kernel_info
function_virual_info
function_net-tools_info
function_netbridge_info00
function_qemu_info
function_libvirt_info
function_netbridge_info01
}
Main_Check-Env
