#!/bin/env bash 
# Usage : Install_LNMP's scripts of shell
# Author : hukenis@163.com


# judge_OS(){}    # 判断操作系统是否是Centos7|8
# judge_RAM(){}   # 判断内存是否充足
# judge_USER(){}  # 判断用户权限是否足够


 #########################################
 #              VERSION                  #
 #########################################

        Version_of_Nginx="1.22.0"
        Version_of_Php="7.4.30"
        Version_of_Mysql="5.7.34"

 ##########################################
 #           SOURCE PACKAGE               # 
 ##########################################

source_package_Nginx="/opt/source_package/nginx"
source_package_Php="/opt/source_package/php"
source_package_Mysql="/opt/source_package/mysql"

 ##########################################
 #             INSTALL DIR                #
 ##########################################
  
  nginx_install_Dir="/usr/local/nginx"
  php_install_Dir="/usr/local/php"
  mysql_install_Dir="/usr/local/mysql"

  Mysql_DataDir="/data/mysql_data"

# ::::::::::::::::::::::::::::::::::::::::::: #

 ###########################################
 #         --COMPILE ENVIRONMENT--         # 
 ###########################################

prepare_env(){

echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] Environment ${print_info00} install  \n " && sleep 2
yum -y install epel-release
yum -y install  centos-release-scl  gcc gcc-c++ make zlib zlib-devel pcre pcre-devel libjpeg libjpeg-devel libpng libpng-devel freetypefreetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-develnss_ldap openldap-clients openldap-servers libxslt libxslt-devel  oniguruma oniguruma-devel sqlite-devel cmake

yum -y install openssl-devel bzip2-devel libffi-devel  sqlite-devel gpm-libs oniguruma oniguruma-devel libsodium libsodium-devel xz-devel libxml2-devel libcurl-devel
yum -y install pcre-devel
yum -y install  bash-completion bash-completion-extras libicu-devel libjpeg libjpeg-devel  nss_ldap cmake  boost-devel libevent libevent-devel gd gd-devel openjpeg-devel
yum -y install  libgcrypt-devel libpng-devel libgpg-error-devel libxslt-devel cmake libmcrypt-devel libmcrypt  recode-devel recode
}


### NGINX_INSTALL###
#  VERSION 1.22.0  #
####################
 
download_nginx(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] NGINX-${Version_of_Nginx} ${print_info00} Download  \n " && sleep 2
mkdir -p ${source_package_Nginx} && cd ${source_package_Nginx}
curl -O http://nginx.org/download/nginx-${Version_of_Nginx}.tar.gz
if [  $? -ne  0 ];then
retry_download_nginx01
fi
}
 
retry_download_nginx00(){
read -p  "下载失败，是否重试？（Y|N）" choice01
        case $choice01 in
        Y|y|yes|Yes)
        sleep 3
        download_nginx
        ;;
        N|n|no|No)
        sleep 1
        echo "bye ~";exit
        ;;
        esac
}

retry_download_nginx01(){
until
retry_download_nginx00
do
retry_download_nginx00
done
}

install_nginx(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] NGINX-${Version_of_Nginx} ${print_info00} Install  \n " && sleep 2
mkdir -p /usr/local/nginx/tmp/nginx/client/
useradd -s /sbin/nologin nginx -M

cd ${source_package_Nginx} && tar xvf nginx-${Version_of_Nginx}.tar.gz && cd ${source_package_Nginx}/nginx-${Version_of_Nginx}
(./configure --prefix=${nginx_install_Dir}/nginx --sbin-path=${nginx_install_Dir}/sbin/nginx/nginx --conf-path=${nginx_install_Dir}/conf/nginx.conf --error-log-path=${nginx_install_Dir}/log/error.log --http-log-path=${nginx_install_Dir}/log/access.log --pid-path=${nginx_install_Dir}/run/nginx/nginx.pid --lock-path=${nginx_install_Dir}/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=${nginx_install_Dir}/tmp/nginx/client/ --http-proxy-temp-path=${nginx_install_Dir}/tmp/nginx/proxy/ --http-fastcgi-temp-path=${nginx_install_Dir}/tmp/nginx/fcgi/ --http-uwsgi-temp-path=${nginx_install_Dir}/tmp/nginx/uwsgi --http-scgi-temp-path=${nginx_install_Dir}/tmp/nginx/scgi --with-pcre)&& make && make install

cd ${nginx_install_Dir}/sbin/nginx/nginx
echo "PATH=$PWD:\$PATH" > /etc/profile.d/nginx.sh
}

Initialize_NG_configuration(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] NGINX-${Version_of_Nginx} ${print_info00} Initialization  \n " && sleep 2
local  program_of_thread="auto"               ## Nginx 进程配置
local  php_hostAndPort="127.0.0.1:9000"      ## Php 主机及端口指定


cat <<EOF >/usr/local/nginx/conf/nginx.conf

#user  nobody;
worker_processes  auto;
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
#pid        logs/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    #log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    #                  '\$status \$body_bytes_sent "\$http_referer" '
    #                  '"\$http_user_agent" "\$http_x_forwarded_for"';
    #access_log  logs/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    #gzip  on;
    server {
        listen       80;
        server_name  localhost;
        #charset koi8-r;
        #access_log  logs/host.access.log  main;
        location / {
            root   html;
            index  index.html index.htm;
        }
        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
        root   html;
        }
        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts\$fastcgi_script_name;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }
        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }
    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;
    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
 # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;
    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;
    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;
    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;
    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
}

EOF
}

###PHP_INSTALL###
# VERSION 8.0.0 #
#################

download_php(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] PHP-${Version_of_Php} ${print_info00} Download  \n " && sleep 2
mkdir -p ${source_package_Php} && cd ${source_package_Php}
curl -O https://www.php.net/distributions/php-${Version_of_Php}.tar.gz
if [ $? -ne  0 ];then
retry_download_php01
fi
}

retry_download_php00(){
read -p  "下载失败，是否重试？（Y|N）" choice02
        case $choice02 in
        Y|y|yes|Yes)
        sleep 3
        download_php
        ;;
        N|n|no|No)
        sleep 1
        echo "bye ~";exit
        ;;
        esac
}

retry_download_php01(){
until
retry_download_php00
do
retry_download_php00
done
}

install_php(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] PHP-${Version_of_Php} ${print_info00} Install  \n " && sleep 2
cd ${source_package_Php} && tar -xvf php-${Version_of_Php}.tar.gz && cd ${source_package_Php}/php-${Version_of_Php}

(./configure --prefix=${php_install_Dir}/ --with-config-file-path=${php_install_Dir}/etc --with-fpm-user=nginx --with-fpm-group=nginx --with-curl  --enable-gd --with-gettext --with-iconv-dir --with-kerberos --with-libdir=lib64  --with-mysqli --with-openssl  --with-pdo-mysql --with-pdo-sqlite --with-pear   --with-xmlrpc --with-xsl --with-zlib --with-bz2 --with-mhash --enable-fpm --enable-bcmath  --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-sysvshm --enable-xml  --enable-fpm  --with-freetype --with-jpeg  --with-xpm)&&make &&make install 

#(./configure --prefix=/usr/local/php8 --with-curl --with-mysql-sock=/var/tmp/mysql/mysql.sock --with-jpeg-dir --with-freetype-dir --with-gd --with-gettext --with-iconv-dir --with-kerberos --with-libxml-dir --with-mysqli=mysqlnd --with-openssl --with-pcre-regex --with-pdo-mysql=mysqlnd --with-pdo-sqlite --with-pear --with-png-dir --with-xmlrpc --with-xsl --with-zlib --with-pdo-mysql --with-fpm-user=nginx --with-fpm-group=nginx --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-gd-native-ttf --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-xml --enable-zip --enable-mysqlnd --enable-maintainer-zts)&& make && make install 

# (./configure --prefix=/usr/local/php --with-config-file-path=/usr/local \  
# /php/etc --with-bz2 --with-curl --enable-ftp --enable-sockets \
# --disable-ipv6 --with-gd --with-jpeg-dir=/usr/local --with-png-dir=/usr/local \
# --with-freetype-dir=/usr/local --enable-gd-native-ttf --with-iconv-dir=/usr \
# /local --enable-mbstring --enable-calendar --with-gettext --with-libxml- \
# dir=/usr/local --with-zlib --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd \
#  --with-mysql=mysqlnd --enable-dom --enable-xml --enable-fpm --with- \
# libdir=lib64 --enable-bcmath --enable-ctype --without-pear --disable-phar)

}

Initialize_PHP_configuration00(){
cd ${php_install_Dir}/etc 
cp -rf  php.ini  php.ini~
sed -i -e  '/;date.timezone =/a date.timezone = Asia\/Shanghai'     php.ini
sed -i -e  's/post_max_size = 8M/; post_max_size = 8M/g'            php.ini
sed -i -e  '/; post_max_size = 8M/a  post_max_size = 16M'           php.ini
sed -i -e  's/max_input_time = 60/; max_input_time = 60/g'          php.ini
sed -i -e  '/; max_input_time = 60/a max_input_time = 300'          php.ini
sed -i -e  's/max_execution_time = 30/; max_execution_time = 30/g'  php.ini
sed -i -e  '/; max_execution_time = 30/a  max_execution_time = 300' php.ini
}

Initialize_PHP_configuration(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] PHP-${Version_of_Php} ${print_info00} Initialization  \n " && sleep 2
cp ${source_package_Php}/php-${Version_of_Php}/php.ini-production ${php_install_Dir}/etc/php.ini
cd ${php_install_Dir}/etc && cp php-fpm.conf.default php-fpm.conf
cd ${php_install_Dir}/etc/php-fpm.d/ && cp www.conf.default www.conf
Initialize_PHP_configuration00
cd ${php_install_Dir}/sbin && echo "PATH=$PWD:\$PATH" > /etc/profile.d/php.sh
cp ${source_package_Php}/php-${Version_of_Php}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && chmod +x  /etc/init.d/php-fpm
}



###MYSQL_INSTALL###
#  VERSION 5.7.34 #
###################
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
(cmake -DCMAKE_INSTALL_PREFIX=${mysql_install_Dir}  -DMYSQL_UNIX_ADDR=${mysql_install_Dir}/bin/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_BOOST=boost)&&make && make install
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


./${mysql_install_Dir}/bin/mysqld --initialize --user=mysql --console && echo "initialize commplete" # 初始化指令

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

#  INFO  BEACON :::::::::::::::
print_beacon='[INFO_SCRIPTS]'
print_info00='is about to be '
print_error='[ERROR_SCRIPTS]'

# time_format: [TIME: `date "+%Y-%m-%d %H:%M:%S"`] 
# Usage_Of_Example: echo -e "\n${BEACON}-[TIME] ITEM-VERSION ${INFO0x} ACTION  \n " && sleep 2
# ::::::::::::::::::::::::::::::::::::::::::::::

NGINX_INSTALL_00(){
download_nginx
#install_nginx >/dev/null 2&>1
install_nginx 
## 自定义配置路径的选择 ，待补充
Initialize_NG_configuration
}


PHP_INSTALL_00(){
 download_php
 install_php 
# 自动义配置路径的选择，待补充
 Initialize_PHP_configuration
}

MYSQL_INSTALL_00(){
 download_mysql
 install_mysql
 Initialize_Mysql_configuration
}

#START_LNMP(){}

Main(){
prepare_env
NGINX_INSTALL_00
PHP_INSTALL_00
MYSQL_INSTALL_00
}

Main
