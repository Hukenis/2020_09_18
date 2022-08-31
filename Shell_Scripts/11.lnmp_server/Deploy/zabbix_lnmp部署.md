# zabbix概述
## 部署 （仅限于Centos7th_OS）
    建议源码部署，并不是为了装杯，为了便于升级以及各个插件模块的多功能和拓展。
### Nginx
1.    环境准备
       yum -y install gcc gcc-c++ make zlib zlib-devel pcre pcre-devel libjpeg libjpeg-devel libpng libpng-devel freetypefreetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libxslt libxslt-devel  oniguruma oniguruma-devel sqlite-devel
2.     源码下载
        