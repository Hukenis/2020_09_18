#!/bin/bash

innobackupex=innobackupex
innobackupexFull=/usr/bin/${innobackupex}
today=`date +%Y%m%d%H%M`
yesterday=`date -d"yesterday" +%Y%m%d%H%M`
yesterday2=`date -d"yesterday" +%F`
user="root"
password="6#cziP2_22"
logFile="/var/log/backup_mysql/${today}.log"
myConf=/etc/my.cnf
mysql=/usr/local/mysql/bin/mysql
mysqlAdmin=/usr/local/mysql/bin/mysqladmin
backupDir=/data/backup
fullBackupDir=${backupDir}/full
incBackupDir=${backupDir}/incr
serverIp=211.155.80.123

# 定义错误输出函数
error(){
	echo -e "\033[31m ${1} \033[0m" >&2
	exit 1
}

blue(){
	echo -e "\033[36m ${1} \033[0m"	
}

green(){
	echo -e "\033[32m ${1} \033[0m"
}

# 在备份之前检查参数
if [ ! -d /var/log/backup_mysql ];then
	mkdir -p /var/log/backup_mysql
fi

if [ ! -x ${innobackupexFull} ];then
	error "${innobackupexFull} does not exist."
fi

if [ ! -d ${backupDir} ];then
	error "${backupDir} does not exist."
fi

if [ -z "`${mysqlAdmin} -u${user} -p${password} status |grep 'Uptime'`" ];then
	error "mysql does not appear to be running."
fi

if ! `echo 'exit' |${mysql} -s -u${user} -p${password}`;then
	error "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)."

fi

# 输出开始信息
blue "----------------------------"
blue " "
blue "$0: MySQL backup script"
blue "started: `date`"
blue " "

# 判断目录是否存在
for dir in ${fullBackupDir} ${incBackupDir}
do
	if [ ! -d ${dir} ];then
		mkdir -p ${dir}
	fi
done

deleteFile(){
	# 删除12天之前的备份
	find ${backupDir}/ -maxdepth 1 -type f -name "*.gz" -mtime "+2" |xargs rm -f
}

fullBackup(){
	cd ${backupDir}
	# 删除上周的全量和增量备份
	find ${backupDir}/ -maxdepth 1 -type d -name "full" |xargs rm -rf
	find ${backupDir}/ -maxdepth 1 -type d -name "incr" |xargs rm -rf
	if [ $?=0 ];then
		green "running new full backup."
		# 开始新的全备
		${innobackupexFull} --defaults-file=${myConf} -u${user} -p${password} ${fullBackupDir} >/${logFile} 2>&1
	else
		error "error with 'find ${backupDir}/ -maxdepth 1 -type d -name "full"'"
	fi

	if [ -z "`tail -1 ${logFile} |grep 'completed OK!'`" ];then
		mutt -s "${serverIp}:MySQL全量备份失败" kai.wu@wifiin.com <${logFile}
		error "${innobackupexFull} filed:";echo
		error "---------- ERROR OUTPUT from ${innobackupexFull} ----------"
	fi
	# 获取这次备份的目录
	thisBackup=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" ${logFile}`
	green "thisBackup=${thisBackup}"
	green "Databases backed up successfully to: ${thisBackup}"
        blue
        blue "full backup completed: `date`"
        blue "-----------------------------"
	size=`du -sh ${thisBackup}`
	#echo "${size}" |mutt -s "${serverIp}:MySQL全量备份完成" kai.wu@wifiin.com
        
        # 每周一回传当天的全量备份数据
	tar -zcf ${serverIp}.${today}.full.tar.gz ./full
	if [ $?=0 ];then
		scp -P 62815 ${serverIp}.${today}.full.tar.gz developer@dev.wifiin.cn:/data/backup/speedin/
		if [ $?=0 ];then
			green "success with scp."
                        echo "
                              线上服务器：${serverIp}
                              备份文件：${serverIp}.${today}.full.tar.gz
                              备份文件大小：`du -sh ${serverIp}.${today}.full.tar.gz|awk '{print $1}'`
                              备份服务器：内网 172.16.1.46 
                              目录：/data/backup/speedin" |mutt -s "通知: SpeedinMySQL备份拷贝完成" kai.wu@wifiin.com
		else
			error "error with scp."
                        for i in {1..3}
                        do
                        echo "
                              线上服务器：${serverIp}
                              备份文件：${serverIp}.${today}.full.tar.gz
                              备份文件大小：`du -sh ${serverIp}.${today}.full.tar.gz|awk '{print $1}'`
                              备份服务器：内网 172.16.1.46
                              目录：/data/backup/speedin" |mutt -s "警告: SpeedinMySQL备份拷贝失败" kai.wu@wifiin.com
                        done
		fi
	fi
	
	
}

incrBackup(){
	# 查看昨天的全量备份
	latestFull=`find ${fullBackupDir} -mindepth 1 -maxdepth 1 -type d -name "${yesterday2}*"`
	green "latestFull=${latestFull}"
	# 查看昨天的增量备份
	latestIncr=`find ${incBackupDir} -mindepth 1 -maxdepth 1 -type d -name "${yesterday2}*"`
	green "latestIncr=${latestIncr}"

	if [ -z ${latestFull} ];then
		incrBaseDir=${latestIncr}
	else
		incrBaseDir=${latestFull}
	fi
	green "Running new incremental backup using ${incrBaseDir} as base."
	${innobackupexFull} --defaults-file=${myConf} -u${user} -p${password} --incremental ${incBackupDir} --incremental-basedir ${incrBaseDir} >${logFile} 2>&1
	
	if [ -z "`tail -1 ${logFile} |grep 'completed OK!'`" ];then
		mutt -s "${serverIp}:MySQL增量备份失败" kai.wu@wifiin.com <${logFile}
		error "${innobackupexFull} failed:";echo
		error "---------- ERROR OUTPUT from ${innobackupexFull} ----------"
	fi

	# 获取这次备份的目录
	thisBackup=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" ${logFile}`
	green "thisBackup=${thisBackup}"
	green " " 
	green "Databases backed up successfully to: ${thisBackup}"

	blue
	blue "incremental completed: `date`"
	blue "-----------------------------"
	size=`du -sh ${thisBackup}`
	echo "${size}" |mutt -s "${serverIp}:MySQL增量备份完成" kai.wu@wifiin.com
	exit 0	
}

options(){
	cat <<- EOF
	Usage: $0 <full | incr>
	OPtions:
	    full 		full backup
	    incr 		incremental backup
	EOF
}

case $1 in
	full)
	deleteFile
	fullBackup
	;;
	incr)
	incrBackup
	;;
	*)
	options
esac
