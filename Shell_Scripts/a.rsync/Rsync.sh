#!/bin/env bash 

local_dir="/data/remote_history"
remote_dir="/data/www/wifiin/logs/remote_history/2022-06-22"
remote_user="sremanager"
remote_ip="111.200.62.165"

Rsync_funciton(){
rsync --append  -P -are 'ssh -p 62815 '  ${local_dir}/  ${remote_user}@${remote_ip}:${remote_dir}
}


Rsync_funciton

# -------------------------------------------# 

remote_passwd="jHDvNOwNQPDL74os0jhD7OYPHYc650"


expect_function(){
expect <<EOF
set timeout 20
spawn   bash /opt/scripts/Rsync.sh
expect {

        "*password:" {send "${remote_passwd}\r"}
}       
expect eof
EOF
}

