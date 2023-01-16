#!/usr/bin/env bash
#>
#> Usage: Speed To Create Virt Machines  --快速创建 KVM 虚拟机
#> date: 2022.07.07
#> author: hukenis@163.com

MACHINES_CONFIG_PATH="/etc/libvirt/qemu"
MACHINES_TEMPLATE_DISK_PATH="/data/kvm/vm_disks/Template"
MACHINES_ALL_DISK_PATH="/data/kvm/vm_disks"
HEIP_DOC="/opt/scripts/kvm/Readme.txt"
# MACHINES_VNC_PORT=$2
# MACHINES_NAME=$1

#-------------------- 工作环境检查 ------------------#
if	[ ! -d "${MACHINES_CONFIG_PATH}"    ];then
	echo " 核验QEMU是否安装，配置文件路径是否存在 " && exit
fi

if	[ ! -d "${MACHINES_TEMPLATE_DISK_PATH}"  ];then
	echo " 模板介质路径不存在 "${MACHINES_TEMPLATE_DISK_PATH}"" && exit
fi

if	[ ! -d "${MACHINES_ALL_DISK_PATH}"  ];then
	mkdir -p ${MACHINES_ALL_DISK_PATH}
fi

if	[ ! -f "${HEIP_DOC}"  ];then
	echo " 帮助手册丢失.. "
fi

if 	[ ! -f ${MACHINES_TEMPLATE_DISK_PATH}/template_machines.raw ];then
	echo "模板介质不存在，或请修改模板名字为脚本标准 >> template_machines.raw << " && exit 
fi

if	[ ! -f ${MACHINES_CONFIG_PATH}/template_machines.xml ];then
	echo "模板配置文件不存在，或请修改模板名字为脚本标准  >> template_machines.xml  << "
fi


HEIP_IDEA(){
cat  ${HEIP_DOC} 
}

Read_STDIN(){		# 定义 输入虚拟名字和端口
read -p " 输入 虚拟机名字以及用于连接的VNC端口 "  env1  env2
MACHINES_NAME=$env1
MACHINES_VNC_PORT=$env2
}


Check_Port(){ 		# 检查 VNC端口是否存在
echo "${MACHINES_VNC_PORT}" | [ -n "`sed -n '/^[0-9][0-9]*$/p'`" ]
	if [ $? != 0  ];then
		echo " 端口号设定为非法字段 "&&  exit

	fi
ss -anptl | grep "${MACHINES_VNC_PORT}" 2>1&>/dev/null
	if  [ $? == 0 ];then
		echo " VNC_Port is exist ，想要继续创建虚拟机的话，那你必须再想一个用于 VNC 端口 " ; exit
	fi
}


Check_NAME(){		# 检查 机器名字是否存在
local NEW_DISK_PATH=${MACHINES_ALL_DISK_PATH}/${MACHINES_NAME}
        if  [ -e ${NEW_DISK_PATH}  ];then
                echo " 已存在同名的虚拟机相关文件"&&exit
        fi

virsh list --all | grep "${MACHINES_NAME}"
	if  [ $? == 0  ];then
		echo " NAME is exist ，要继续创建虚拟机的话，你必须想个独一无二的 NAME  "  ; exit
	else
		sudo mkdir ${MACHINES_ALL_DISK_PATH}/${MACHINES_NAME}
	fi
}


Create_DISK(){		# 创建 磁盘介质    ：使用已有的磁盘模板进行二创
qemu-img create -f qcow2 -b ${MACHINES_TEMPLATE_DISK_PATH}/template_machines.raw  ${MACHINES_ALL_DISK_PATH}/${MACHINES_NAME}/${MACHINES_NAME}.qcow2 2>&1>/dev/null
	if  [ $? != 0  ];then
		echo ; echo " 介质盘创建失败 ~"
	else
		echo ; echo " loading ... "
	fi
}


Create_XML(){		# 创建 XML配置文件 ：使用已有的模板机配置文件进行二创
cp -rf  ${MACHINES_CONFIG_PATH}/{template_machines.xml,${MACHINES_NAME}.xml} && local NEW_XML=${MACHINES_NAME}.xml || echo " 样板配置拷贝失败 ~ "
sed -ri "s/Template/${MACHINES_NAME}/"       ${MACHINES_CONFIG_PATH}/${NEW_XML} 
sed -ri "s/VNC_PORT/${MACHINES_VNC_PORT}/"    ${MACHINES_CONFIG_PATH}/${NEW_XML}
virsh define ${MACHINES_CONFIG_PATH}/${NEW_XML} 2>&1>/dev/null
}


Start_MECHINE(){	# 启动 ··· 并查看状态
ln -s ${MACHINES_ALL_DISK_PATH}/${MACHINES_NAME}/${MACHINES_NAME}.qcow2  ${MACHINES_ALL_DISK_PATH}/${MACHINES_NAME}.qcow2
virsh start ${MACHINES_NAME} && echo " 启动成功 ~~" || ( exit ; echo " 启动失败" )
echo;echo "######### SHOW MECHINE STATUS #########"
virsh list --all | grep "${MACHINES_NAME}"
}


CONFIRM(){		# 确认执行 以及 执行动作
	echo " Name is ${MACHINES_NAME} ; VNC_Port is ${MACHINES_VNC_PORT} "
	read -p " Please confirm before continuing (Yes/No) :   "  CHOICE1
	while true
	do
	case  ${CHOICE1} in 
		y|Y|yes|Yes|YES)
		echo " The Machine Will Be Created ~~";
		Create_DISK	
		Create_XML
		Start_MECHINE
		#echo "will create disk "
		#echo "will create xml "
		#echo "will start  kvm "
		break
		;;

		n|N|no|No|NO|quit)
		echo " 即将返回标题 " &&clear;rmdir ${MACHINES_ALL_DISK_PATH}/${MACHINES_NAME} ;break
	esac
	done
}


Create_MAIN(){        # 执行
Read_STDIN
Check_Port
Check_NAME
CONFIRM
##Create_DISK    ## 并入 ‘CONFIRM’ 功能中，反复确认后选项中触发创建
##Create_XML     ## 并入 ‘CONFIRM’ 功能中，同上
##Start_MECHINE  ## 并入 ‘CONFIRM’ 功能中，同上
}


Interactive(){		# 入口菜单界面，
while [1]
do
	cat <<EOF
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@   Speed To Create Virt Machines   @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	· 扣1 获取帮助
	· 扣2 执行
	· 扣3 退出
EOF

read -p "输入选项:::    "  CHOICE2
case ${CHOICE2} in 
	1|help|h|H)
	HEIP_IDEA
	;;
 
	2|go|carry_on)
	echo ; echo " loading ··· " && sleep 1 ;echo 
	Create_MAIN
	;;

	3|quit|exit|Q)
	echo ;echo "bye ~";exit
esac


done
}

Interactive

#Create_Main_00(){
#
	#ss -anptu | grep ":$2"	   		#检查端口是否存在
	#if [ $? -ne 0 ];then
	#  virsh list --all | grep "$1"
	#  if [ $? -ne 0 ];then
	#    qemu-img create -f qcow2 -b ${MACHINES_DISK_PATH}/template_machines.raw ${MACHINES_DISK_PATH}/$1.qcow2
	#    cp ${MACHINES_CONFIG_PATH}/{template_machines.xml,$1.xml}
	#    sed -ri "s/NAME/$1/" ${MACHINES_CONFIG_PATH}/$1.xml
	#    sed -ri "s/VNCPORT/$2/" ${MACHINES_CONFIG_PATH}/$1.xml
	#    virsh define ${MACHINES_CONFIG_PATH}/$1.xml
	#    virsh start $1
	#  else
	#    echo "this machines is exist!!! :$1"
	#  fi
	#else
	#  echo "this port is exist!!! :$2"
	#fi
#}
#
