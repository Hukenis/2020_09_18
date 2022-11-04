#!/bin/bash
# Date  : 2022_11_04
# Auther: wukai@sandstar.com


create_ip_logDir(){
ip_logDir="/home/sandstar/wukai/ping_log"
mkdir -p ${ip_logDir}

Today_dir="${ip_logDir}/`date  +%Y%m%d`"
mkdir -p ${Today_dir}

# date  +[%Y%m%d_%H:%M:%S][info]
}

create_ip_logDir


if [[  -z $1  ]];then 

	read -p "Please specify the test file or ip_address :   " machine_ip
else
	machine_ip=$@
fi

if [[  -f ${machine_ip}  ]];then 
	# echo ${machine_ip} is a file
	ip=`cat ${machine_ip}` 
	echo -e "`date  +[%Y%m%d_%H:%M:%S][info]` : Ping_command Debug log  " >>${Today_dir}/ping_all.log

	(for i in ${ip};
	do	
		ping -c 3  ${i} >>  ${Today_dir}/ping_all.log && echo -e "\n"
			if	[   $? -eq 0 ];then 
				echo -e "`date  +[%Y%m%d_%H:%M:%S][info]`  $i is ok "|tee -a  ${Today_dir}/ping_tong.log
			else
				echo -e "\n"
				echo -e "`date  +[%Y%m%d_%H:%M:%S][warring]` $i is Unreachable " | tee -a  ${Today_dir}/ping_failed.log
			fi
	done)&
else
	# echo ${machine_ip} is not file 
	(for i in  ${machine_ip}
	do
		ping -c 3  ${i} >>  ${Today_dir}/ping_all.log && echo -e "\n "
		if      [   $? -eq 0 ];then
                                echo  -e "`date  +[%Y%m%d_%H:%M:%S][info]` ${i} is ok " |tee -a  ${Today_dir}/ping_tong.log
                        else
				echo -e "\n"
                                echo  -e "`date  +[%Y%m%d_%H:%M:%S][warring]` ${i} is Unreachable " | tee -a  ${Today_dir}/ping_failed.log
                fi
	done)& 

fi

## 注 ：核心功能不可以放入函数中调用，否则会丧失第一次传参的能力，会直接触发 " read -p "，提示换行输入。
