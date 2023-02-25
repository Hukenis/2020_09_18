#!/bin/bash 
# usage  : create new kvm-machine case
# auther : hukenis@163.com
# date   : 2023-02-25 01:45 AM 

# 讯息时间戳 定义
today=`date +[%Y-%m-%d]`
i_msg=`date +[%Y-%m-%d" "%H:%M:%S" "INFO]`
w_msg=`date +[%Y-%m-%d" "%H:%M:%S" "WARRING]`
e_msg=`date +[%Y-%m-%d" "%H:%M:%S" "ERROR]`
trap "echo 'Script Exited~'" EXIT

# work_dir=/data/kvm/machines
# disk_dir=/data/kvm/machines/vm_disks
# iso_dir=/data/iso_image

# 工作目录定义
declare -A run_path
run_path=([work_dir]="/data/kvm_machines"\
          [disk_dir]="/data/kvm_machines/vm_disks"\
          [iso_dir]="/data/iso_image"\
          [Template]="/data/kvm_machines/Template")


# kvm-qemu 环境检测
preparation(){
[[ -z `which virt-install` || -z `which virsh` || -z `which libvirtd` ]]&& (echo -e "${e_msg} The kvm environment is not ready. Please check and execute this script after installation";exit)

for dir in ${!run_path[@]}
do 
    if [[ ! -e ${run_path[$dir]} ]];then
        echo -e "${w_msg}   Work path ${run_path[$dir]}    not found" && p_input ${run_path[$dir]}
    fi
done
}


# 镜像与虚拟磁盘目录
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

# 镜像检测
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

# 镜像下载
iso_download(){
case $1 in 
    CentOS-7-x86_64-Minimal-2207-02.iso)
    wget -O ${run_path[iso_dir]}/$1 -c http://mirrors.aliyun.com/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2207-02.iso  
	if [[ $? -ne 0  ]];then
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

# 下载失败重试 limit 3次
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

# 虚拟机交互定义
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
        do
            read -p "Give a name to the virtual machine :" NAME
            if [[ -z $NAME ]];then
                echo -e "name cannot be empty !"
            elif [[ -n `virsh list --all | awk 'NR>2{print $0}' |grep -ow  ${NAME}`  ]];then
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
                if    [[  -z `echo $HDD|egrep  '^[0-9]+$'` ]];then 
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
                         echo -e "Bad Port !"
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

# 配置确认
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
esac
done
}


# 创建镜像
qume_image_Create(){
qemu-img create -f qcow2 -o size=${HDD}G ${run_path[disk_dir]}/${NAME}.qcow2
if [ $? -ne 0 ];then
    echo -e "${e_msg} Disk creation Failed!!!!!!";exit 44
fi
}

check_template(){
if [[ `echo $1 |grep centos_7` == "centos_7"  ]];then
    temp_origin="centos7_temp"
elif [[ `echo $1 |grep ubuntu_22` == "ubuntu_22"  ]];then
    temp_origin="ubuntu_22_temp"
fi

TEMP_PATH="${run_path[work_dir]}/Template"
MACHINES_CONFIG_PATH="/etc/libvirt/qemu"
MACHINES_TEMPLATE_DISK="${TEMP_PATH}/${temp_origin}.qcow2"
MACHINES_TEMPLATE_CONFIG="${TEMP_PATH}/${temp_origin}.xml"

if    [[ !  -e ${TEMP_PATH}/${temp_origin}.qcow2  ]];then
        echo  -e "${e_msg}  Template image: ${temp_origin}.qcow2 NOT FOUND ! " ;exit     
elif  [[ !  -e ${MACHINES_TEMPLATE_CONFIG} ]];then
        echo  -e "${e_msg}  Template config_file:  ${temp_origin}.xml NOT FOUND ! " ;exit
fi
}

# 模板创建虚机时，镜像二创
qume_image_Clone(){      # 创建 磁盘介质    ：使用已有的磁盘模板进行二创
while true;
do
    Poor_capacity=$(($HDD-10))
        if [[ ${Poor_capacity} -lt 0 ]];then
              echo -e "${e_msg} Size cannot be less than 10G"
              read -p "Reset Strage size" HDD
        else
              HDD=$((${HDD}+${Poor_capacity}))
              break
        fi
done

HDD_PATH="${run_path[disk_dir]}/${NAME}.qcow2"
# qemu-img create -f qcow2 -F qcow2 -b  $MACHINES_TEMPLATE_DISK  $HDD_PATH  # Ubuntu22上出现了此问题，不添加-F参数就无法继续创建
qemu-img create -f qcow2  -b  $MACHINES_TEMPLATE_DISK  $HDD_PATH
qemu-img resize $HDD_PATH  +${HDD}G
if  [ $? != 0  ];then
    echo ; echo " 介质盘创建失败 ~"
else
    echo ; echo " loading ... "
fi
}

# 模板创建虚拟机时，配置文件二创
XML_crate(){
cp -rf  ${MACHINES_TEMPLATE_CONFIG} ${MACHINES_CONFIG_PATH}/${NAME}.xml  &&  NEW_XML=${NAME}.xml || echo " 样板配置拷贝失败 ~ "
sed -ri "s/Template/${NAME}/"       ${MACHINES_CONFIG_PATH}/${NEW_XML}
sed -ri "s/VNCPort/${Port}/"        ${MACHINES_CONFIG_PATH}/${NEW_XML}
sed -ri "s/RAM/${RAM}/g"   	        ${MACHINES_CONFIG_PATH}/${NEW_XML}
sed -ri "s/Cores/${Cores}/"         ${MACHINES_CONFIG_PATH}/${NEW_XML}
sed -ri "s#HDD_PATH#${HDD_PATH}#"   ${MACHINES_CONFIG_PATH}/${NEW_XML}
}

# 常规部署
_install(){
   virt-install --name=${NAME} \
 --vcpus=${Cores} --memory=${RAM} --disk=${run_path[disk_dir]}/${NAME}.qcow2 \
 --cdrom=${run_path[iso_dir]}/$1 \
 --noautoconsole --autostart \
 --network bridge=br0 \
 --graphics vnc,listen=0.0.0.0,port=${Port}\
 --osinfo detect=on,require=off
   if [ $? -ne 0 ];then
       echo -e "${e_msg} Installation Failed!!!!!!";exit 44
   fi
#  --os-variant=linux2020 \
}

# 选项C  常规部署centos7
centos_7_install(){
iso_image_name="CentOS-7-x86_64-Minimal-2207-02.iso"
iso_check ${iso_image_name}
v_input   
qume_image_Create 
_install  ${iso_image_name}
}

# 选项D  常规部署ubuntu
ubuntu_22_install(){
iso_image_name="ubuntu-22.04.1-live-server-amd64.iso"
iso_check ${iso_image_name}
v_input
qume_image_Create
_install  ${iso_image_name}
}

# 模板急速部署 centos7
centos_7_fast_install(){
check_template    centos_7
v_input
XML_crate         centos_7
qume_image_Clone  centos_7
virsh define ${MACHINES_CONFIG_PATH}/${NEW_XML} 2>&1>/dev/null
# 公共前提：kvm 环境
# 模板前提：xml配置文件、模板磁盘
# 配置选项：name ram hdd vncport
# 模板配置好处： 对母体进行初始化后，克隆出来的子体省去了初始化流程

}

# 模板急速部署 ubuntu
ubuntu_22_fast_install(){
check_template    ubuntu_22
v_input
XML_crate         ubuntu_22
qume_image_Clone  ubuntu_22
virsh define ${MACHINES_CONFIG_PATH}/${NEW_XML} 2>&1>/dev/null
echo -e "${i_msg} The template password is： root1/k_00"
}

# 快照操作设备选择
select_machine(){
if    [[ -z `virsh list --all| awk 'NR>2{print $2}'|egrep -v '^$'`  ]];then
         echo -e "${w_msg} There is no vtrual machine, go and create one!";exit
fi

while true;
do
        virsh  list --all
        read -p "select A Machine [TYPE NAME]:  " DOMAIN
        if   [[ $DOMAIN == "exit" ]];then
                Snapshot_action
        fi
        vm_list=`virsh list --all| awk 'NR>2{print $2}'|egrep -v '^$'`
        
        if [[ -n `echo $vm_list | grep $DOMAIN`  ]];then
             break
        else
            echo -e "${w_msg} Confirm that your machine already exists!"
        fi
        
done
}

# 快照创建
snapshot_create(){
select_machine
read -p "Name for snapshot [TYPE NAME]:  " SNAP_NAME
read -p "Add a description for snapshot [TYPE RESUME]:  " RESUME
if [[ -z ${SNAP_NAME}  ]];then
        virsh snapshot-create $DOMAIN
        echo -e "${i_msg} You created an anonymous snapshot" && break
else    
        
        if [[ -z ${RESUME} ]];then
                virsh snapshot-create-as --domain $DOMAIN --name "$SNAP_NAME"
                echo -e "${i_msg} Snapshot ${SNAP_NAME} of ${DOMAIN} has been created " && break
        else
                virsh snapshot-create-as --domain $DOMAIN --name "$SNAP_NAME" --description "$RESUME"
                echo -e "${i_msg} Snapshot ${SNAP_NAME} of ${DOMAIN} has been created " && break
        fi
fi
}

# 恢复快照
Snapshot_recovery(){
select_machine
if [[ -z `virsh snapshot-list  ${DOMAIN}|awk 'NR>2{print $1}' |egrep -v '^$'` ]];then
        echo -e "${w_msg} There is no snapshot for ${DOMAIN}, go and create one!";exit
fi
while true;
do
        virsh snapshot-list $DOMAIN
        read -p "select A Snapshot [TYPE NAME]:  " SNAP_NAME
        for i in `virsh snapshot-list  ${DOMAIN}|awk 'NR>2{print $1}' |egrep -v '^$'`
        do
               if     [[ $SNAP_NAME == "exit" ]];then
                      break
               elif   [[ -z `echo $i | grep $SNAP_NAME`  ]];then
                       echo -e "${w_msg} Confirm that your snapshot already exists! "
               else
                       virsh snapshot-revert $DOMAIN  $SNAP_NAME --running
                       echo -e "${i_msg} Snapshot :${SNAP_NAME}  restored!" && break
               fi
        done

done 
}


# 删除快照
Snapshot_delete(){
select_machine
if [[ -z `virsh snapshot-list  ${DOMAIN}|awk 'NR>2{print $1}' |egrep -v '^$'` ]];then
        echo -e "${w_msg} There is no snapshot for ${DOMAIN}, go and create one!";exit
fi
while true;
do
        virsh snapshot-list $DOMAIN
        read -p "select A Snapshot [TYPE NAME]:  " SNAP_NAME
        for i in `virsh snapshot-list  ${DOMAIN}|awk 'NR>2{print $1}' |egrep -v '^$'`
        do     
               if      [[ $SNAP_NAME == "exit" ]];then
                       break
               elif    [[ -z `echo $i | grep $SNAP_NAME`  ]];then
                       echo -e "${w_msg} Confirm that your snapshot already exists! " && clear
               else
                       virsh snapshot-delete $DOMAIN  $SNAP_NAME
                       echo -e "${i_msg} Snapshot :${SNAP_NAME} deleted!"
               fi
        done

done
}

# 删除虚拟机
delete_VM(){
while true;
do
        select_machine
        read -p "confirm deletion ${DOMAIN}  [yes/no]:  " confirm
        case $confirm in 
                yes|Y|y|YES)

                rm -rf  `grep "source file"  ${DOMAIN} | awk -F "'" '{print $2}'`
                virsh define  $DOMAIN
                echo -e "${i_msg} VM: ${DOMAIN} deleted"
                ;;
                no|N|n|No)
                break
                ;;
                *)
                echo -e "yes or no ?"
                ;;
        esac
done 
}

# 快照操作菜单
Snapshot_action(){
while true;
do
cat <<EOF
+

        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        @        Snapshot Operation         @
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                a.  Create   Snapshot
                b.  Rollbak  Snapshot
                c.  Delete   Snapshot
                e.  Previous Menu                 
                                                  +

EOF
    read -p "START YOUR CHOICE : " choice00
    case $choice00 in
        A|a)
        snapshot_create       
        ;;
        B|b)
        Snapshot_recovery
        ;;
        C|c)
        Snapshot_delete
        ;;
        E|e)
        clear && memu_display
        ;;
        *)
        echo -e "\n\n\npleasecallme5429" 
        ;;
    esac
done 

}


# 菜单展示
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
    read -p "START YOUR CHOICE : " choice01
    case $choice01 in 
        A|a)
        centos_7_fast_install
        ;;
        B|b)
        ubuntu_22_fast_install
        ;;
        C|c)
        centos_7_install
        ;;
        D|d)
        ubuntu_22_install
        ;;
        E|e)
        Snapshot_action
        ;;
        F|f)
        delete_VM       
        ;;
        H|h)
        if [[ -e ${help_doc}  ]];then
                less ${help_doc}
        else
                echo -e "${w_msg} Help document does not exist"
        fi
        ;;
        Q|q|exit)
           exit 77
        ;;
        R|r|refresh)
            sync && clear
        ;;
        *)
        echo -e "\n\n\npleasecallme5429" 
        ;;
    esac
done
}

# 入口触发

Main(){
preparation
memu_display
}
Main
