#!/bin/bash
###################################################################################
# File Name     : deploy.sh
# Description   : code deploy and rollback scripts
# Author        : guo yuming
# Mail          : shmilyjinian@163.com
# Created Time  : 2017-01-23 16:25:43 PM
# Modify Time   : 2018-12-18 14:14:53 PM
###################################################################################

# Version 1.1.8
# Modify Time: 2018-12-18 14:14
# Modify the function: code_push(), add varibale "ANSIBLE_PROJECT_NAME" and temporarily separate"blue/green"scripts

# Version 1.1.6
# Modify Time : 2018-02-28 16:00:00
# Add parameters: blue/green release

# Version 1.1.5
# Modify Time : 2018-01-29 19:25:00
# Modify the function: code_config(), add uat environment configuration file

# Version 1.1.4
# Modify Time : 2018-01-16 19:17:00
# Modify the function: code_config() 

# Version 1.1.3
# Modify Time : 2018-01-15 11:48:00
# Add parameters: PROJECT_TAG and the deploy code can use version number
# uat environment will use the dev configuration file

# Version 1.1.1
# Delete lock code

# Version 1.1.0
# Add rollback function

# Version 1.0.0
# Add deploy function

# Source function library 	加载init全局文件
. /etc/init.d/functions 

# Shell Env  	指定工作环境
SHELL_DIR='/opt/scripts'
SHELL_NAME='deploy-1.1.8.sh'
SHELL_LOG="${SHELL_DIR}/deploy.log"   	# 部署推送日志
LOCK_FILE='/tmp/deploy.lock'

# Date/Time variables	 时间戳
LOG_DATE="date +%F"
LOG_TIME="date +%T"
C_DATE=`date +%F`
C_TIME=`date +%H-%M-%S`

# Ansible variables  	Ansible环境指定
PLAYBOOK_DIR="/ansible/playbooks"
PLAYBOOK_DEPLOY_DIR="${PLAYBOOK_DIR}/deploy"
PLAYBOOK_DEPLOY_HOSTS_DIR="${PLAYBOOK_DEPLOY_DIR}/hosts"

# Code variables  	选择构建产品环境
deploy_env(){
    #DEPLOY_ENV=$1
    case ${DEPLOY_ENV} in
      dev|developer)		# 测试环境产品目录
        CODE_DIR="/deploy/dev_deploy/code"
        CONFIG_DIR="/deploy/dev_deploy/config"
        TMP_DIR="/deploy/dev_deploy/tmp"
        ;;
      uat)			# 预生产环境产品目录
        CODE_DIR="/deploy/uat_deploy/code"
        CONFIG_DIR="/deploy/uat_deploy/config"
        TMP_DIR="/deploy/uat_deploy/tmp"
        ;;
      pro|production)		# 生产环境产品目录
        CODE_DIR="/deploy/pro_deploy/code"
        CONFIG_DIR="/deploy/pro_deploy/config"
        TMP_DIR="/deploy/pro_deploy/tmp"
        ;;
      *)			# 其他提示信息
	echo -e "Usage: $0 <options> <deploy_env>\n" 
	echo -e "Deploy_env:"
	echo "  dev, --developer          Deploy developer enviroment"
	echo "  uat,                      Deploy user acceptance test enviroment"
	echo -e "  pro, --product            Deploy production enviroment\n"
	echo -e "Example:\n$0 -d production"
	exit 1
    esac
}


# write log function   日志记录
write_log(){
    LOG_INFO=$1   # 此处$1 对应下面的函数功能块中字符串
    echo "$(${LOG_DATE}) $(${LOG_TIME}) ${SHELL_NAME} ${LOG_INFO}" >> ${SHELL_LOG}
}

# get code function   
code_get(){
    #PROJECT_NAME=$1
    write_log "[INFO] get ${PROJECT_NAME} code"
    if [ -z ${PROJECT_NAME} ];then   # 判断产品名字 是否为空
	echo -e "Usage: $0 <options> <deploy_env> <project_name> [tag] [blue|green]\n"
	echo -e "Example:\n  $0 -d pro wifiin-server-core"
	exit 2
    fi

    if [ ! -d ${TMP_DIR}/${PROJECT_NAME} ];then	 # 临时打包目录不存在则创建
	mkdir -p ${TMP_DIR}/${PROJECT_NAME}
    fi

    if [ -d ${CODE_DIR}/${PROJECT_NAME} ];then	 # 将构建好的产品拷贝进临时目录里，并记录
        cp -r ${CODE_DIR}/${PROJECT_NAME} ${TMP_DIR}/${PROJECT_NAME}
        write_log "[INFO] copy ${CODE_DIR}/${PROJECT_NAME} to ${TMP_DIR}/${PROJECT_NAME}"
    else
	echo "[ERROR] The ${DEPLOY_ENV} envrioment ${PROJECT_NAME} code does not exist"
	write_log "[ERROR] ${DEPLOY_ENV} envrioment ${PROJECT_NAME} code does not exist"
	exit 3
    fi
}

# copy to config file function  拷贝配置文件
code_config(){		 
    if [ ! -d ${CONFIG_DIR}/${PROJECT_NAME}/base/ ];then 
        mkdir -p ${CONFIG_DIR}/${PROJECT_NAME}/base
	mkdir -p ${CONFIG_DIR}/${PROJECT_NAME}/other
    fi

    /bin/cp -r ${CONFIG_DIR}/${PROJECT_NAME}/base/* ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes
    write_log "[INFO] copy ${CONFIG_DIR}/${PROJECT_NAME}/base/* config file to ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes"

    cd ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes/
    if [ ${DEPLOY_ENV} == 'pro' ];then
        #\cp ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes/product.constant.properties ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes/current.constant.properties
        #write_log "copy ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes/product.constant.properties to ${TMP_DIR}/${PROJECT_NAME}/${PROJECT_NAME}/current/WEB-INF/classes/current.constant.properties"

	FILE_LIST=(`find ./ -maxdepth 1 -type f -name "product.*"`)  # 
	FILE_NUMBER=`echo ${#FILE_LIST[*]}`
	if [ ${FILE_NUMBER} -eq 0 ];then
	    echo " "
	else
	    for FILE_NEW in `echo ${FILE_LIST[*]}`
	    do
		FILE_OLD=`echo ${FILE_NEW} |awk -F 'product.' '{print $1$2}'`
		\cp ${FILE_NEW} ${FILE_OLD}
		write_log "copy ${FILE_NEW} to ${FILE_OLD}"
	    done
	fi
    elif [ ${DEPLOY_ENV} == 'dev' ];then
        FILE_LIST=(`find ./ -maxdepth 1 -type f -name "test.*"`)
        FILE_NUMBER=`echo ${#FILE_LIST[*]}`
        if [ ${FILE_NUMBER} -eq 0 ];then
            echo " "
        else
            for FILE_NEW in `echo ${FILE_LIST[*]}`
            do
                FILE_OLD=`echo ${FILE_NEW} |awk -F 'test.' '{print $1$2}'`
                \cp ${FILE_NEW} ${FILE_OLD}
                write_log "copy ${FILE_NEW} to ${FILE_OLD}"
            done
        fi
    elif [ ${DEPLOY_ENV} == 'uat' ];then
        FILE_LIST=(`find ./ -maxdepth 1 -type f -name "uat.*"`)
        FILE_NUMBER=`echo ${#FILE_LIST[*]}`
        if [ ${FILE_NUMBER} -eq 0 ];then
            echo " "
        else
            for FILE_NEW in `echo ${FILE_LIST[*]}`
            do
                FILE_OLD=`echo ${FILE_NEW} |awk -F 'uat.' '{print $1$2}'`
                \cp ${FILE_NEW} ${FILE_OLD}
                write_log "copy ${FILE_NEW} to ${FILE_OLD}"
            done
        fi
    fi


    if [ -z $PROJECT_TAG ];then
        PACKAGE_NAME=${PROJECT_NAME}_${C_DATE}-${C_TIME}
    else
	if [[ ${PROJECT_TAG} == "blue" ]] || [[ ${PROJECT_TAG} == "green" ]];then
		echo -e "Usage: $0 <options> <deploy_env> <project_name> [tag] [blue|green]\n"
		echo -e "Example:\n  $0 -d pro wifiin-server-core release-1.12.1 blue"
		exit
	else
        	PACKAGE_NAME=${PROJECT_NAME}-${PROJECT_TAG}_${C_DATE}-${C_TIME}
	fi
    fi
    cd ${TMP_DIR}/${PROJECT_NAME} && mv ${PROJECT_NAME} ${PACKAGE_NAME}
}

# code package function
code_tar(){  # 压缩产品准备推送
    if [ ! -d ${TMP_DIR}/${PROJECT_NAME} ];then
        mkdir -p ${TMP_DIR}/${PROJECT_NAME}
    fi
    write_log "[INFO] tar ${PROJECT_NAME} code"
    cd ${TMP_DIR}/${PROJECT_NAME} && tar Jcf ${PACKAGE_NAME}.tar.xz $PACKAGE_NAME
    write_log "[INFO] tar ${PROJECT_NAME} code success package name ${PACKAGE_NAME}.tar.xz"
}

# push and deploy function
code_push(){	# 推送产品
    DEPLOY_HOSTS_FILE=${DEPLOY_ENV}-${PROJECT_NAME}-hosts

    if [ -z ${DEPLOY_MODE} ];then
	DEPLOY_HOSTS_FILE=${DEPLOY_ENV}-${PROJECT_NAME}-hosts
    else
    	if [[ ${DEPLOY_MODE} == "blue" ]] || [[ ${DEPLOY_MODE} == "green" ]];then
        	DEPLOY_HOSTS_FILE=${DEPLOY_ENV}-${PROJECT_NAME}-${DEPLOY_MODE}-hosts
    	else
        	echo -e "Usage: $0 <options> <deploy_env> <project_name> [tag] [blue|green]\n"
		echo -e "Example:\n  $0 -d pro wifiin-server-core release-1.2.1 blue"
		exit
    	fi
    fi

    write_log "[INFO] push code to remote hosts and deploy code"

    # 一下内容为临时修改------------------------------------------------------
    # 将blue/green部署脚本分开,定义参数 ANSIBLE_PROJECT_NAME
    ANSIBLE_PROJECT_NAME=${PROJECT_NAME}
    if [ -n ${DEPLOY_MODE} ];then
        if [[ ${DEPLOY_MODE} == "blue" ]];then
            ANSIBLE_PROJECT_NAME=${PROJECT_NAME}-blue
        fi
    fi

    # 用ANSIBLE_PROJECT_NAME替换部分PROJECT_NAME
    if [ ! -d ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars ];then
	mkdir -p ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars
	write_log "[INFO] create directory ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars"
    fi

    echo -e "deploy_src_code_name: /opt/deploy/code/${PACKAGE_NAME}\ndest_code_name: /data/www/wifiin/wsapp/${ANSIBLE_PROJECT_NAME}\nsrc_package_name: ${TMP_DIR}/${PROJECT_NAME}/${PACKAGE_NAME}.tar.xz" > ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars/main.yml

    if [ -f ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars/main.yml ] && [ -n ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars/main.yml ];then
        cd ${PLAYBOOK_DEPLOY_DIR} && ansible-playbook -i ${PLAYBOOK_DEPLOY_HOSTS_DIR}/${DEPLOY_HOSTS_FILE} ${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}.yml -t deploy -f 1
	if [ $? -eq 0 ];then
	    write_log "[INFO] ${DEPLOY_ENV} ${ANSIBLE_PROJECT_NAME} deploy success"
	fi
    else
	write_log "[ERROR] ${PLAYBOOK_DEPLOY_DIR}/roles/${DEPLOY_ENV}-${ANSIBLE_PROJECT_NAME}/vars/main.yml is not exist or nonzero"
	exit 4
    fi
    # 以上内容为临时修改----------------------------------------------------
}

# code rollback options function
rollback_options(){
    case $ROLLBACK_ARG in
      -l|--list)
	write_log "[INFO] list ${ROLLBACK_ENV} ${PROJECT_NAME} code"
	cd ${PLAYBOOK_DEPLOY_DIR} && ansible -i ${PLAYBOOK_DEPLOY_HOSTS_DIR}/${DEPLOY_HOSTS_FILE} ${ROLLBACK_ENV}-${PROJECT_NAME} -m shell -a "ls -lrthd --time-style=long-iso /opt/deploy/code/${PROJECT_NAME}*"
	;;
      -v|--version)
	if [ -z ${PROJECT_VERSION} ];then
	    action "Please input project version" /bin/false
	    write_log "[ERROR] no input project version"
	    echo "Example:"
	    echo "  /opt/deploy/code/invpn-server-core_2017-02-23-17-33-04"
	    exit 5
	fi
	sed -i '/rollback_src_code_name/d' ${PLAYBOOK_DEPLOY_DIR}/roles/${ROLLBACK_ENV}-${PROJECT_NAME}/vars/main.yml
	echo -e "rollback_src_code_name: ${PROJECT_VERSION}" >> ${PLAYBOOK_DEPLOY_DIR}/roles/${ROLLBACK_ENV}-${PROJECT_NAME}/vars/main.yml
	if [ `grep "\<rollback_src_code_name\>" ${PLAYBOOK_DEPLOY_DIR}/roles/${ROLLBACK_ENV}-${PROJECT_NAME}/vars/main.yml|wc -l` -eq 0 ];then
	    echo "Variables rollback_src_code_name is not found from ${PLAYBOOK_DEPLOY_DIR}/roles/${ROLLBACK_ENV}-${PROJECT_NAME}/vars/main.yml"
	    write_log "[ERROR] Variables rollback_src_code_name is not found from ${PLAYBOOK_DEPLOY_DIR}/roles/${ROLLBACK_ENV}-${PROJECT_NAME}/vars/main.yml"
	    exit 6
        else
	    write_log "[INFO] Perform ${ROLLBACK_ENV} ${PROJECT_NAME} rollback"
	    write_log "[INFO] rollback version ${PROJECT_VERSION}"
	    cd ${PLAYBOOK_DEPLOY_DIR} && ansible-playbook -i ${PLAYBOOK_DEPLOY_HOSTS_DIR}/${DEPLOY_HOSTS_FILE} ${ROLLBACK_ENV}-${PROJECT_NAME}.yml -t rollback -f 1
	    if [ $? -eq 0 ];then
		write_log "[INFO] ${ROLLBACK_ENV} ${PROJECT_NAME} rollback success"
	    fi
	fi
	;;
      *)
	echo "Rollback arguments:"
	echo -e "  -l, --list               List all version code\n  -v, --version            Input code version"
	echo "[blue|green]:"
	echo -e "  blue:                     A production machine\n  green:                    Other production machine\n"
	exit 7
    esac
}

# code rollback function
rollback(){
    case ${ROLLBACK_ENV} in
      dev|developer)
	if [ -z ${PROJECT_NAME} ];then
	    action "Please input project name" /bin/false
	    write_log "[ERROR] The project name is empty"
	    echo -e "Example:\n  $0 -r uat invpn-server-core"
	    exit 8
	else
	    if [ `grep "^\[${ROLLBACK_ENV}-${PROJECT_NAME}\]$" ${PLAYBOOK_DEPLOY_DIR}/${ROLLBACK_HOSTS_FILE}|wc -l` -eq 0 ];then
	        action "Project name ${PROJECT_NAME} not found" /bin/false
		write_log "[ERROR] Project name ${PROJECT_NAME} not found"
	        exit 9
	    else
		rollback_options
	    fi
	fi
        ;;
      uat)
	if [ -z ${PROJECT_NAME} ];then
	    action "Please input project name" /bin/false
	    write_log "[ERROR] The project name is empty"
            echo -e "Example:\n  $0 -r uat invpn-server-core"
            exit 10
        else
            if [ `grep "^\[${ROLLBACK_ENV}-${PROJECT_NAME}\]$" ${PLAYBOOK_DEPLOY_DIR}/${ROLLBACK_HOSTS_FILE}|wc -l` -eq 0 ];then
                action "Project name ${PROJECT_NAME} not found" /bin/false
		write_log "[ERROR] Project name ${PROJECT_NAME} not found"
                exit 11
            else
                rollback_options
            fi
        fi
        ;;
      pro|production)
	if [ -z ${PROJECT_NAME} ];then
            action "Please input project name" /bin/false
	    write_log "[ERROR] The project name is empty"
            echo -e "Example:\n  $0 -r uat invpn-server-core"
            exit 12
        else
            if [ `grep "^\[${ROLLBACK_ENV}-${PROJECT_NAME}\]$" ${PLAYBOOK_DEPLOY_DIR}/${ROLLBACK_HOSTS_FILE}|wc -l` -eq 0 ];then
                action "Project name ${PROJECT_NAME} not found" /bin/false
		write_log "[ERROR] Project name ${PROJECT_NAME} not found"
                exit 13
            else
                rollback_options
            fi
        fi
        ;;
      *)
        echo -e "Usage: $0 <options> <rollback_env> <project_name> [project_version] [blue|green]\n"
        echo -e "Rollback_env:"
        echo "  dev, --developer          Rollback developer enviroment"
        echo "  uat,                      Rollback user acceptance test enviroment"
        echo -e "  pro, --product            Rollback production enviroment\n"
	echo "Rollback arguments:"
        echo -e "  -l, --list               List all version code\n  -v, --version            Input code version\n"
	echo "[blue|green]:"
	echo -e "  blue:                     A production machine\n  green:                    Other production machine\n"
        echo -e "Example:\n  $0 -r uat invpn-server-core -l"
	echo -e "  $0 -r uat invpn-server-core -v /opt/deploy/code/invpn-server-core_2017-02-23-17-33-04"
        exit 14
    esac
}

# show usage function
show_usage(){
cat <<EOF
Usage: $0 <options> <arguments>
       $0 -d <deploy_env> <project_name> [tag] [blue|green]
       $0 -r <rollback_env> <project_name> {rollback_arguments} [project_version] [blue|green]

Options:
  -d, --deploy             Deploy code
  -r, --rollback           Rollback code

Deploy or Rollback env:
  -dev, --developer        Deploy or rollback developer enviroment
  -uat,                    Deploy or rollback user acceptance test enviroment
  -pro, --production       Deploy or rollback production enviroment

Project_name:
  wifiin-server-core
  wifi-sdk-server-core
  ......

Code_tag:
  tag                      Select the version number of the code

[blue|green]
  blue			   Deploy the code to a production machine
  green			   Deploy the code to other production machine

Rollback_arguments:
  -l, --list               List all version code
  -v, --version            Input code version
EOF
exit 0
}

# main function
main(){
    DEPLOY_METHOD=$1
    case $DEPLOY_METHOD in
      -d|--deploy)
	DEPLOY_ENV=$2
	PROJECT_NAME=$3
	PROJECT_TAG=$4
        DEPLOY_MODE=$5
	deploy_env $DEPLOY_ENV
	code_get $PROJECT_NAME $PROJECT_TAG
	code_config
	code_tar
	code_push
	;;
      -r|--rollback)
	ROLLBACK_ENV=$2
	PROJECT_NAME=$3
	ROLLBACK_ARG=$4
	PROJECT_VERSION=$5
	ROLLBACK_MODE=$6
    ROLLBACK_HOSTS_FILE=${ROLLBACK_ENV}-hosts
    if [ -n ${PROJECT_VERSION} ];then
        if [[ ${PROJECT_VERSION} == "blue" ]] || [[ ${PROJECT_VERSION} == "green" ]];then
                ROLLBACK_HOSTS_FILE=${ROLLBACK_ENV}-${PROJECT_VERSION}-hosts
        fi
    fi
    if [ -n ${ROLLBACK_MODE} ];then
        if [[ ${ROLLBACK_MODE} == "blue" ]] || [[ ${ROLLBACK_MODE} == "green" ]];then
            ROLLBACK_HOSTS_FILE=${ROLLBACK_ENV}-${ROLLBACK_MODE}-hosts
        fi
    fi
	rollback $ROLLBACK_ENV $PROJECT_NAME $ROLLBACK_ARG $PROJECT_VERSION $ROLLBACK_MODE
	;;
      -h|--help)
	#clear
	show_usage
	;;
      *)
	#clear
	show_usage
    esac
}

main $*
