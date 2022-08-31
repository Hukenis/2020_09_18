#!/bin/env bash
# RSYNC 保证大文件传输不中断
# BY hukenis@163.com

remote_passwd="jHDvNOwNQPDL74os0jhD7OYPHYc650"


expect_function(){
expect <<EOF
set timeout 200
spawn   bash /opt/scripts/Rsync.sh
expect {

	"*password:" {send "${remote_passwd}\r"}
}	
expect eof
EOF
}

Main(){
until 
expect_function
do
	 expect_function
done 
}

Main
