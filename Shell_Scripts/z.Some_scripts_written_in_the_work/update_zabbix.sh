#!/bin/env bash 
# Date   : 2022-09-05
# Usage  : 批量替换zabbix可执行程序实现升级。
# Auther : hukenis@163.com

judge_os(){
if [`awk -F "release" '{print $2}' /etc/redhat-release  |cut -d . -f 1` -ne 7 ];then
	echo "The Execution Object Must Be Centos7 !";exit
fi
}

zabbix_pid=`ps -ef| grep  zabbix_agentd[[:space:]]  | awk 'NR==1{print $2}'`
zabbix_path=` ls -l /proc/${zabbix_pid}  | awk '/zabbix_agentd/{print $11}'|awk -F "sbin" '{print $1}'`
zabbix_sbin_="${zabbix_path}/sbin/zabbix_agentd"
zabbix_bin_1="${zabbix_path}/bin/zabbix_get"
zabbix_bin_2="${zabbix_path}/bin/zabbix_sender"
zabbix_conf=`ps -ef| grep zabbix |grep -v grep  | awk -F "-c" 'NR==1{print $2}'`

update_path="/tmp/other_uploadfile"
update_file="${update_path}/zabbix.tar"
update_sbin="${update_path}/zabbix/zabbix_agentd"
update_bin_1="${update_path}/zabbix/zabbix_get"
update_bin_2="${update_path}/zabbix/zabbix_sender"

time_stamp=`date "+%Y_%m_%d-%H:%M"`

judge_update_file(){
file ${update_file}  >/dev/null 2>&1
if [ $? -ne 0  ];then
	echo "not found update_file";exit
else
	tar -xf ${update_file} -C ${update_path}|| echo "Decompression Failed"
fi
}

judge_zabbix_process_status(){
if [[  -z  ${zabbix_pid}  ]];then 
	echo -e "\n`date "+[%Y_%m_%d %H:%M:%S]"` ==> Zabbix Is Not Running \n";exit
else
   	echo -e "\n`date "+[%Y_%m_%d %H:%M:%S]"` ==> Zabbix Is Running \n"
fi
}


backups(){
cp -rf ${zabbix_sbin_} ${zabbix_sbin_}.${time_stamp}||exit 3 
cp -rf ${zabbix_bin_1} ${zabbix_bin_1}.${time_stamp}||exit 3
cp -rf ${zabbix_bin_2} ${zabbix_bin_2}.${time_stamp}||exit 3
}

replace_sbin(){
mv -f ${update_sbin}  ${zabbix_sbin_}||exit  4
mv -f ${update_bin_1} ${zabbix_bin_1}||exit  4
mv -f ${update_bin_2} ${zabbix_bin_2}||exit  4 
}

restart_zabbix(){
systemctl restart zabbix-agent >/dev/null 2>&1
if [ $? -ne 0 ];then
(ps -ef | grep zabbix-agent | grep -v grep | awk '{print $2}' |xargs kill -9)&& (${zabbix_sbin_} -c ${zabbix_conf})
	if [ $? -ne 0 ];then
		echo -e "\n`date "+[%Y_%m_%d %H:%M:%S]"` ==> start is failled ,check it "
	else
		judge_zabbix_process_status
	fi
else
	judge_zabbix_process_status
fi 
}

Main(){
judge_os
judge_update_file
judge_zabbix_process_status
backups
if [ $? -eq 66 ];then
	echo "cp is failed ";exit
fi
replace_sbin&&restart_zabbix
}

Main
