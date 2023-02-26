###MYSQL_INSTALL###
#  VERSION 5.7.34 #
###################
Version_of_Mysql="5.7.34"
source_package_Mysql="/opt/source_package/mysql"
mysql_install_Dir="/usr/local/mysql"
Mysql_DataDir="/data/mysql_data"

mkdir -p  $source_package_Mysql
mkdir -p  $mysql_install_Dir
mkdir -p  $Mysql_DataDir

download_mysql(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] MYSQL-${Version_of_Mysql} ${print_info00} Download  \n "  && sleep 2
mkdir -p ${source_package_Mysql} && cd ${source_package_Mysql}
curl -O https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-${Version_of_Mysql}.tar.gz
if [ $? -ne 0 ];then
retry_download_mysql01
fi
}

retry_download_mysql00(){
read -p  "下载失败，是否重试？（Y|N）" choice03
        case $choice03 in
        Y|y|yes|Yes)
        sleep 3
        download_mysql
        ;;
        N|n|no|No)
        sleep 1
        echo "bye ~";exit
        ;;
        esac
}

retry_download_mysql01(){
until
retry_download_mysql00
do
retry_download_mysql00
done
}

install_mysql(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] MYSQL-${Version_of_Mysql} ${print_info00} Install  \n "  && sleep 2
cd ${source_package_Mysql} && tar -xvf mysql-boost-${Version_of_Mysql}.tar.gz && cd ${source_package_Mysql}/mysql-${Version_of_Mysql}
(cmake -DCMAKE_INSTALL_PREFIX=${mysql_install_Dir}  -DMYSQL_UNIX_ADDR=${mysql_install_Dir}/bin/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_BOOST=boost -DSYSCONFDIR=/etc  -DMYSQL_DATADIR=/data/mysql)&&make `lscpu |awk  '/^CPU\(s\):/ {print $2}'` && make install
}

Initialize_Mysql_configuration(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] MYSQL-${Version_of_Mysql} ${print_info00} Initialization  \n " && sleep 2
grep mysql /etc/passwd >/dev/null 2&>1
if [ $? -ne 0 ];then
        groupadd mysql
        useradd -r -g mysql -s /bin/false mysql
fi

mkdir ${Mysql_DataDir}/logs -p
mkdir ${Mysql_DataDir}/data -p 
touch  ${mysql_install_Dir}/bin/mysqld.pid
touch  ${Mysql_DataDir}/logs/mysqld.log
chmod +755  /data  
chown mysql.mysql ${Mysql_DataDir}  -R 
chown mysql.mysql ${mysql_install_Dir}  -R 


cd ${mysql_install_Dir}/lib && echo "PATH=$PWD:\$PATH" > /etc/profile.d/mysql.sh
cd ${mysql_install_Dir}/bin && echo "PATH=$PWD:\$PATH" >> /etc/profile.d/mysql.sh
source /etc/profile


${mysql_install_Dir}/bin/mysqld --initialize --user=mysql --console && echo "initialize commplete" # 初始化指令

grep  -i "password is generated"  ${Mysql_DataDir}/logs/mysqld.log   # 查看初始密码

cp ${mysql_install_Dir}/support-files/mysql.server /etc/init.d/mysql && chmod +x /etc/init.d/mysql
cat <<EOF  >/etc/my.cnf
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/data/mysql_data/data
socket=/usr/local/mysql/bin/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
log-error=/data/mysql_data/logs/mysqld.log
pid-file=/usr/local/mysql/bin/mysqld.pid
EOF

}
MYSQL_INSTALL_00(){
 download_mysql
 install_mysql
 Initialize_Mysql_configuration
}

MYSQL_INSTALL_00
