#!/bin/env bash 
# Usage  : Zabbix_server install 
# Date   : 2022-08
# Auther : hukenis@163.com 

 #########################
 #	 OVERVIEW	 #
 #########################


 version='5.0.26'
 source_package='/opt/source_package/zabbix'
 data_Dir='/data/zabbix_data'
 
 nginx_install_Dir="/usr/local/nginx"
 php_install_Dir="/usr/local/php"
 mysql_install_Dir="/usr/local/mysql"
 zabbix_install_Dir="/usr/local/zabbix"


 #########################
 #	DOWNLOAD         #
 #########################

download_zabbix(){
mkdir -p ${source_package} && cd ${source_package}
curl -O https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.26.tar.gz
if [  $? -ne  0 ];then
retry_download_zabbix01
fi
}
 
retry_download_zabbix00(){
read -p  "下载失败，是否重试？（Y|N）" choice01
        case $choice01 in
        Y|y|yes|Yes)
        sleep 3
        download_zabbix
        N|n|no|No)
        sleep 1
        echo "bye ~";exit
        esac
}

retry_download_zabbix01(){
until
retry_download_zabbix00
do
retry_download_zabbix00
done
}


install_zabbix(){
cd ${source_package}/zabbix-5.0.26
(./configure --prefix=${zabbix_install_Dir} --with-mysql --with-net-snmp --with-libcurl --enable-server --enable-agent --enable-proxy --with-libxml2 &&  make && make install)&& make &&  make install
}


Initialize_Mysql_configuration(){
grep zabbix /etc/passwd >/dev/null 2&>1
if [ $? -ne 0 ];then
groupadd zabbix
useradd -r -g zabbix  -s /bin/false zabbix 
fi

mkdir -p ${data_Dir}  && chown zabbix.zabbix ${data_Dir}




local create_database="create database zabbix character set utf8 collate utf8_bin;"
local grant_user="grant all on zabbix.* to zabbix@${mysql_Host} identified by 'zabbix';"
local create_user="CREATE USER zabbix@${mysql_Host} IDENTIFIED BY 'zabbix';"

curl ${mysql_Host}:3306  判断对端是否存活
if	[ $? -ne 0 ];then
	echo " mysql_ ${mysql_Host} 3306 is not exist ,will bye ~";exit
fi
	

read -p "Enter the database password: " mysqlpasswd 
mysql -uroot -p${mysqlpasswd} -e ${create_database}
        until [ $? -eq 0 ];
        do
        echo "[INFO_MYSQL]-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] You typed in a bullshit password or Other Shit network reason, hold on ...";sleep 3
        read -p "[INFO_MYSQL]-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] Do you want to continue? (Y/N)"  choice03
                case ${choice03} in 
                yes|Yes|Y|y|YES)
                Initialize_Mysql_configuration
                ;;
                no|NO|No|N|n)
                exit
                ;;
                esac
        done
mysql -uroot -p${mysqlpasswd} -e ${create_user}
mysql -uroot -p${mysqlpasswd} -e ${grant_user}

mysql -p${mysql_Host} -uzabbix -pzabbix zabbix < ${source_package}/zabbix-5.0.26/database/mysql/schema.sql
mysql -p${mysql_Host} -uzabbix -pzabbix zabbix < ${source_package}/zabbix-5.0.26/database/mysql/images.sql
mysql -p${mysql_Host} -uzabbix -pzabbix zabbix < ${source_package}/zabbix-5.0.26/database/mysql/data.sql

}


judge_Initialize_Mysql_Host(){
read -p "[INFO_MYSQL]-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] Output the database address : "  mysql_Host
if [[ ${mysql_Host} -ne localhost ]];then

	regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
	ckStep2=`echo ${mysql_Host} | egrep ${regex} | wc -l`

	until [[ ckStep2 -eq 0 ]];
	do
	echo "[INFO_MYSQL]-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] You typed in a bullshit address, hold on ...";sleep 3
	read -p "[INFO_MYSQL]-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] Do you want to continue? (Y/N)"  choice02
		case ${choice02} in 
		yes|Yes|Y|y|YES)
		judge_Initialize_Mysql_Host
		;;
		no|NO|No|N|n)
		exit
		;;
		esac
	done
else
	Initialize_Mysql_configuration	## 待修正
fi
}


Initialize_ZabbixWeb_configuration(){
cp -rf  ${source_package}/zabbix-5.0.26/ui  ${data_Dir}/
cp -rf  ${source_package}/misc/init.d/fedora/core/*  && chmod +x /etc/init.d/zabbix*
cat <<EOF >${nginx_install_Dir}/conf/conf.d/zabbix.conf 
    server {
        listen       88;
        server_name  localhost;

        root   /data/zabbix_data;
        location / 
        {
        index  index.php index.html index.htm;
    }
    location ~ \.php$ {
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
EOF
}


Main(){
download_zabbix
install_zabbix
judge_Initialize_Mysql_Host ## 这个不需要在函数中去用else判断另一个函数应不应该执行，给exit附上非0的退出码，从函数整体的运行结果来做if判断来决定下一个动作要不要做
Initialize_Mysql_configuration  ## 待修正 
Initialize_ZabbixWeb_configuration
}
