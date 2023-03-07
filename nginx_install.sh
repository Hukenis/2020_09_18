 #########################################
 #              VERSION                  #
 #########################################

        Version_of_Nginx="1.22.0"

 ##########################################
 #           SOURCE PACKAGE               #
 ##########################################

source_package_Nginx="/opt/source_package/nginx"

 ##########################################
 #             INSTALL DIR                #
 ##########################################

  nginx_install_Dir="/data/nginx"



  prepare_env(){

echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] Environment ${print_info00} install  \n " && sleep 2
yum -y install  centos-release-scl  gcc gcc-c++ make zlib zlib-devel pcre pcre-devel libjpeg libjpeg-devel libpng libpng-devel freetypefreetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-develnss_ldap openldap-clients openldap-servers libxslt libxslt-devel  oniguruma oniguruma-devel sqlite-devel cmake
yum -y install openssl openssl-devel make zlib zlib-devel gcc gcc-c++ libtool    pcre pcre-devel
yum -y install openssl-devel bzip2-devel libffi-devel  sqlite-devel gpm-libs oniguruma oniguruma-devel libsodium libsodium-devel xz-devel libxml2-devel libcurl-devel
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
(./configure --prefix=${nginx_install_Dir}/nginx --sbin-path=${nginx_install_Dir}/sbin/nginx --conf-path=${nginx_install_Dir}/conf/nginx.conf --error-log-path=${nginx_install_Dir}/log/error.log --http-log-path=${nginx_install_Dir}/log/access.log --pid-path=${nginx_install_Dir}/run/nginx/nginx.pid --lock-path=${nginx_install_Dir}/lock/nginx.lock --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=${nginx_install_Dir}/tmp/nginx/client/ --http-proxy-temp-path=${nginx_install_Dir}/tmp/nginx/proxy/ --http-fastcgi-temp-path=${nginx_install_Dir}/tmp/nginx/fcgi/ --http-uwsgi-temp-path=${nginx_install_Dir}/tmp/nginx/uwsgi --http-scgi-temp-path=${nginx_install_Dir}/tmp/nginx/scgi --with-pcre)&& make && make install

cd ${nginx_install_Dir}/sbin/nginx/nginx
echo "PATH=$PWD:\$PATH" > /etc/profile.d/nginx.sh
}

Initialize_NG_configuration(){
echo -e "\n${print_beacon}-[TIME: `date "+%Y-%m-%d %H:%M:%S"`] NGINX-${Version_of_Nginx} ${print_info00} Initialization  \n " && sleep 2
local  program_of_thread="auto"               ## Nginx 进程配置
local  php_hostAndPort="127.0.0.1:9000"      ## Php 主机及端口指定


cat <<EOF >${nginx_install_Dir}/conf/nginx.conf
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


NGINX_INSTALL_00(){
prepare_env
download_nginx
#install_nginx >/dev/null 2&>1
install_nginx 
## 自定义配置路径的选择 ，待补充
Initialize_NG_configuration
}

NGINX_INSTALL_00
