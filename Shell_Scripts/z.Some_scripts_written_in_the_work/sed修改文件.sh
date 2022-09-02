#!/bin/env bash 
# Usage : 更新线路切换名单
# Date  : 2022-08-17

test_file='/tmp/test_file'
file_path='/opt/scripts/line_monitor/line_host_list.txt'
echo ${file_path}

Main(){
local OLDIFS="$IFS"  #备份旧的IFS变量
local IFS=$'\n'   #修改分隔符为换行符

New_='
123.6.102.195 cn-hn-ine-gateway-195
'
For

}

For(){
for i in ${New_[@]}
do
echo $i
# sed -i -e "\$a ${i}"  ${test_file}
sed -i -e "\$a ${i}"  ${file_path}
done
}
Main
