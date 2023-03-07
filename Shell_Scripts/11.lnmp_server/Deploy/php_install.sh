 #########################################
 #              VERSION                  #
 #########################################

        Version_of_Php="7.4.30"
 ##########################################
 #           SOURCE PACKAGE               # 
 ##########################################

source_package_Php="/opt/source_package/php"
 ##########################################
 #             INSTALL DIR                #
 ##########################################
  
  php_install_Dir="/data/php"

  ###########################################
 #         --COMPILE ENVIRONMENT--         # 
 ###########################################

prepare_env(){

echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] Environment ${print_info00} install  \n " && sleep 2
yum -y install  centos-release-scl  gcc gcc-c++ make zlib zlib-devel pcre pcre-devel libjpeg libjpeg-devel libpng libpng-devel freetypefreetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-develnss_ldap openldap-clients openldap-servers libxslt libxslt-devel  oniguruma oniguruma-devel sqlite-devel cmake
yum -y install openssl openssl-devel make zlib zlib-devel gcc gcc-c++ libtool    pcre pcre-devel
yum -y install openssl-devel bzip2-devel libffi-devel  sqlite-devel gpm-libs oniguruma oniguruma-devel libsodium libsodium-devel xz-devel libxml2-devel libcurl-devel
yum -y install  bash-completion bash-completion-extras libicu-devel libjpeg libjpeg-devel  nss_ldap cmake  boost-devel libevent libevent-devel gd gd-devel openjpeg-devel
yum -y install  libgcrypt-devel libpng-devel libgpg-error-devel libxslt-devel cmake libmcrypt-devel libmcrypt  recode-devel recode libxml2-devel sqlite-devel
 yum -y install \
 gd \
 libjpeg libjpeg-devel \
 libpng libpng-devel \
 freetype freetype-devel \
 libxml2 libxml2-devel \
 zlib zlib-devel \
 curl curl-devel \
 openssl openssl-devel \
 libwebp-devel \
 libXpm libXpm-devel
dnf -y install libXpm-devel libXext-devel  gmp gmp-devel libicu* icu*  net-snmp-devel libpng-devel libjpeg-devel  freetype-devel  libxslt-devel sqlite-devel  autoconf libwebp-devel gd-devel
}

###PHP_INSTALL###
# VERSION 8.0.0 #
#################

download_php(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] PHP-${Version_of_Php} ${print_info00} Download  \n " && sleep 2
mkdir -p ${source_package_Php} && cd ${source_package_Php}
wget -c  https://www.php.net/distributions/php-${Version_of_Php}.tar.gz
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


PHP_INSTALL_00(){
#   download_php
#  install_php
# 自动义配置路径的选择，待补充
   Initialize_PHP_configuration
}

 PHP_INSTALL_00
# prepare_env
