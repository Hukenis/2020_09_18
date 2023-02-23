#!/bin/bash 
# usage : create new kvm-machine case
# auther: hukenis@163.com


today=`date +[%Y-%m-%d]`
i_msg=`date +[%Y-%m-%d" "%H:%M:%S" "INFO]`
w_msg=`date +[%Y-%m-%d" "%H:%M:%S" "WARRING]`
e_msg=`date +[%Y-%m-%d" "%H:%M:%S" "ERROR]`
trap "echo 'Script Exited~'" EXIT

# work_dir=/data/kvm/machines
# disk_dir=/data/kvm/machines/vm_disks
# iso_dir=/data/iso_image

declare -A run_path
run_path=([work_dir]="/data/kvm_machines"\
          [disk_dir]="/data/kvm_machines/vm_disks"\
          [iso_dir]="/data/iso_image")



preparation(){
[[ -z `which virt-install` || -z `which virsh` || -z `which libvirtd` ]]&& (echo -e "${e_msg} The kvm environment is not ready. Please check and execute this script after installation";exit)

for dir in ${!run_path[@]}
do 
    if [[ ! -e ${run_path[$dir]} ]];then
        echo -e "${w_msg}   Work path ${run_path[$dir]}    not found" && p_input ${run_path[$dir]}
    fi
done
}

p_input(){
while true;
do
    read -p "${i_msg} Whether to create working directory? [yes/no] " choose
    case $choose in 
        yes|y|Y)
            mkdir -p $1
            echo -e "${i_msg} Created $1"&& break
            ;;
        no|n|N)
            echo -e "${w_msg} No working directory detected, please check";exit
            ;;
    esac
done
}

iso_check(){
iso_image=${run_path[iso_dir]}/$1
if   [[ -n  `echo $1 | grep -i centos-7` ]];then
    iso_name=$1
elif [[ -n `echo $1 | grep -i ubuntu ` ]];then
    iso_name=$1
fi

wait
if [[ ! -e ${iso_image} ]];then
    read -p "${i_msg} Whether to download the image [yes/no]: " choose
    case $choose in 
        yes|y|Y)
            echo -e "${i_msg} Downloading image, Please wait..."
            iso_download $1 && iso_check
            ;;
        no|n|N)
            echo -e "${w_msg} No installation media detected, exiting";exit
            ;;
    esac
fi
}

iso_download(){
case $1 in 
    CentOS-7-x86_64-Minimal.iso)
    wget -O ${run_path[iso_dir]}/$1 -c http://mirrors.aliyun.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2207-02.iso  
	if [[ $? -n   echo -e "Bad Port !"
                elif  [[  -n  `ss -anptl | grep "$Port"`  ]];then
                         echo -e " Port exists and conflicts !"
                elif  [[ $Port -le 5960   ]];then
                         echo -e "Invalid vnc port ! "
                else
                          break
                fi
        done
    fi
done
wait
echo -e "${i_msg} The \"${NAME}\" setting is : \n--------\n\t\t\t\tRAM= ${RAM}Mb\n\t\t\t\tStorage= ${HDD}G\n\t\t\t\tCPU_cores= ${Cores}\n\t\t\t\tVNCPort= ${Port}\n"
var_confirm
}

var_confirm(){
while true;
do
read -p " Confirm? [yes/no/quit]" choice_00
case ${choice_00} in
    yes|y|Y)
        echo "Configuration saved! " ;break
        ;;
    no|n|N)
        unset NAME
        unset RAM
        unset HDD
        unset Cores
        unset Port
        echo -e "\nThe parameters have been reset, please retype" 
        v_input
        ;;
    exit|quit|q)
        echo "Program exit!";exit 77
        ;;
    *)
        echo "Please confirm !"  
        ;;
esae 0  ]];then
		download_retry $1  
	fi
    ;;
    ubuntu-22.04.1-live-server-amd64.iso)
    wget -O ${run_path[iso_dir]}/$1 -c https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/22.04/ubuntu-22.04.1-live-server-amd64.iso
	if [[ $? -ne 0  ]];then
		download_retry $1 
	fi
  ;;
esac
}

download_retry(){
retry=1
until  [[ $retry == 3  ]];
do
	retry=$(( $retry+1  ))
	case $1 in
	   CentOS-7-x86_64-Minimal.iso)
	   wget -O ${run_path[iso_dir]}/$1 -c http://mirrors.aliyun.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2207-02.iso  && break
	    ;;
	   ubuntu-22.04.1-live-server-amd64.iso)
	   wget -O ${run_path[iso_dir]}/$1 -c https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/22.04/ubuntu-22.04.1-live-server-amd64.iso  && break
	esac
done

if [[ $? -ne 0 ]];then
rm -rf ${run_path[iso_dir]}/$1
echo -e "${e_msg} Download failed. Please upload the image manually" && exit
fi
}

v_input(){
var_list="
NAME
RAM
Storage
CPU
PORT
"

for var in $var_list
do 
    if   [[ $var == NAME ]];then
        while true;
 +$'` ]];then 
                         echo -e "Invalid Parameter !"
                elif  [[ $HDD -gt 1000  ]];then
                         echo -e "Not so many resources !"
                else
                         break
                fi
        done
    elif [[ $var == CPU  ]];then
        while true;
        do
            read -p "Type preset CPU cores :"   Cores
            core_num=`grep -c ^processor /proc/cpuinfo`
            limit_num=$(($core_num/2))
                if    [[  -z `echo $Cores|egrep  '^[0-9]+$'` ]];then
                         echo -e "Invalid Parameter !"
                elif  [[ $Cores  -ge $limit_num  ]];then
                         echo -e "Not so many resources !"
                else
                        break
                fi
        done
    elif [[ $var == PORT  ]];then
        while true;
        do 
            read -p "Type preset VNC Port  :"   Port
                if    [[  -z `echo $Port|egrep  '^[0-9]+$'` || $Port -ge 65535 ]];then
                      }


_install(){
   virt-install --name=${NAME} \
 --os-variant=linux2020 \
 --vcpus=${Cores} --memory=${RAM} --disk=${run_path[disk_dir]}/${NAME}.qcow2 \
 --cdrom=${run_path[iso_dir]}/$1 \
 --noautoconsole --autostart \
 --network bridge=br0 \
 --graphics vnc,listen=0.0.0.0,port=${Port}
   if [ $? -ne 0 ];then
       echo -e "${e_msg} Installation Failed!!!!!!";exit 44
   fi
}

centos_7_install(){
iso_image_name="CentOS-7-x86_64-Minimal-2207-02.iso"
iso_check ${iso_image_name}
v_input   
qume_image_Create 
_install  ${iso_image_name}
}

ubuntu_22_install(){
iso_image_name="ubuntu-22.04.1-live-server-amd64.iso"
iso_check ${iso_image_name}
v_input
qume_image_Create
_install  ${iso_image_name}
}

centos_7_fast_install(){
v_input
qume_image_Clone  centos_7
XML_crate         centos_7
# 公共前提：kvm 环境
# 模板前提：xml配置文件、模板磁盘
# 配置选项：name ram hdd vncport

# 模板配置好处： 对母体进行初始化后，克隆出来的子体省去了初始化流程
# }

# ubunutu_22_fast_install(){
# 
#
}

ubuntu_22_fast_install(){
v_input
qume_image_Clone  ubuntu_22
XML_crate         ubuntu_22
}



memu_display(){
while true;
do
cat <<EOF

+-----
|
|
             -------------------------------
             | Creation of virtual machines|
             -------------------------------
    
  OPTIONS:
            A.  CENTOS_7  INSTALL  FAST            
            B.  UBUNTU_22 INSTALL  FAST            
            C.  CENTOS_7  DEPLOY                   
            D.  UBUNTU_22 DEPLOY
            E.  Specify Mirror RollBACK
            F.  Remove virtual machine absolutely
            H.  HELP                               
            Q.  EXIT                                 
            R.  Refresh 
                                                         |
                                                         |
                                                    _____|
EOF
    read -p "START YOUR CHOICE :" choice
    case $choice in 
        A|a)
           centos_7_fast_install
          do
            read -p "Give a name to the virtual machine :" NAME
            if [[ -z $NAME ]];then
                echo -e "name cannot be empty !"
            elif [[ -n `virsh list --all | awk 'NR>2{print $0}' |grep -o  ${NAME}`  ]];then
                echo -e "The name has been registered!"
            else
                break
            fi
        done
    elif [[ $var == RAM ]];then
        while true;
        do
            read -p "Type preset RAM     size [MB] :" RAM
                if    [[  -z `echo $RAM|egrep  '^[0-9]+$'` ]];then
                            echo -e "Invalid Parameter !"
                elif  [[ $RAM -gt `free -m | awk 'NR==2 {print $2}'`  ]];then 
                            echo -e "Not so many resources !"
                else
                        break 
                fi
        done 
    elif [[ $var == Storage ]];then
        while true;
        do
            read -p "Type preset Storage size [G]  :" HDD
                if    [[  -z `echo $HDD|egrep  '^[0-9]eate -f qcow2 -b  ${MACHINES_TEMPLATE_DISK} ${run_path[disk]}/${NAME}.qcow2  2>&1>/dev/null

qemu-img resize ${run_path[disk]}/${NAME}.qcow2 +${HDD}G
if  [ $? != 0  ];then
    echo ; echo " 介质盘创建失败 ~"
else
    echo ; echo " loading ... "
fi
}


XML_crate(){
if [[ `echo $1 |grep centos_7` == "centos_7"  ]];then
    temp_origin="centos7_temp"
elif [[ `echo $1 |grep ubuntu_22` == "ubuntu_22"  ]];then
    temp_origin="ubuntu_22_temp"
fi
local TEMP_PATH="${run_path[work_dir]}/Template"
local MACHINES_CONFIG_PATH="/etc/libvirt/qemu"
local MACHINES_TEMPLATE_DISK="${TEMP_PATH}/${temp_origin}.qcow2"
local MACHINES_TEMPLATE_CONFIG="${TEMP_PATH}/${temp_origin}.xml"

cp -rf  ${MACHINES_TEMPLATE_CONFIG} ${MACHINES_CONFIG_PATH}/${NAME}.xml  && local NEW_XML=${NAME}.xml || echo " 样板配置拷贝失败 ~ "
sed -ri "s/Template/${NAME}/"       ${MACHINES_CONFIG_PATH}/${NEW_XML}
sed -ri "s/VNC_PORT/${PORT}/"       ${MACHINES_CONFIG_PATH}/${NEW_XML}
virsh define ${MACHINES_CONFIG_PATH}/${NEW_XML} 2>&1>/dev/null
        echo -e "模板急速部署"
           echo -e "敬请期待..." &&  sleep 1 && clear
        ;;
        B|b)
           ubuntu_22_fast_install
           echo -e "模板急速部署"
           echo -e "敬请期待..." &&  sleep 1 && clear
        ;;
        C|c)
        centos_7_install
        ;;
        D|d)
        ubuntu_22_install
        ;;
        E|e)
           echo -e "敬请期待";exit 77
        ;;
        F|f)
           echo -e "敬请期待";exit 77
        ;;
        H|h)
           echo -e "敬请期待";exit 77
        ;;
        Q|q|exit)
           exit 77
        ;;
        R|r|refresh)
            clear
        ;;
        *)
            clear ;sleep 1&& echo -e "\n\n\npleasecallme5429" 
        ;;
    esac
done
}


Main(){
preparation
memu_display
}

Main
c
done
}

qume_image_Create(){
qemu-img create -f qcow2 -o size=${HDD}G ${run_path[disk_dir]}/${NAME}.qcow2
if [ $? -ne 0 ];then
    echo -e "${e_msg} Disk creation Failed!!!!!!";exit 44
fi
}

qume_image_Clone(){      # 创建 磁盘介质    ：使用已有的磁盘模板进行二创
if  [[ `echo $1 |grep centos_7` == "centos_7"  ]];then
    temp_origin="centos7_temp"
elif [[ `echo $1 |grep ubuntu_22` == "ubuntu_22"  ]];then
    temp_origin="ubuntu_22_temp"
fi
local TEMP_PATH="${run_path[work_dir]}/Template"
local MACHINES_TEMPLATE_DISK="${TEMP_PATH}/${temp_origin}.qcow2"

cp -rf  ${MACHINES_TEMPLATE_CONFIG} ${MACHINES_CONFIG_PATH}/${NAME}.xml  && local NEW_XML=${NAME}.xml || echo " 样板配置拷贝失败 ~ "
# 添加xml_create 相同的变量定义
while true;
do
    Poor_capacity=$(($HDD-10))
        if [[ ${Poor_capacity} -lt 0 ]];then
              echo -e "${e_msg} Size cannot be less than 10G"
        else
              HDD=$((${HDD}+${Poor_capacity}))
              break
        fi
done

qemu-img cr