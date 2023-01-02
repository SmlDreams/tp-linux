#!/bin/bash

echo "Machine name : $(hostnamectl --static)"
echo "OS $(cat /etc/redhat-release) and kernel version is $(uname -s -r)"
echo "IP : $(ip a | grep inet | grep enp0s8 | tr -s ' ' | cut -d' ' -f3)"
echo "RAM : $(free -h | grep Mem | tr -s ' ' | cut -d' ' -f7) memory available on $(free -h | grep Mem | tr -s ' ' | cut -d' ' -f2) total memory"
echo "Disk : $(df -h | grep root | tr -s ' ' | cut -d' ' -f4) space left"
echo "Top 5 processes by RAM usage :"
a="$(ps -o command= ax --sort=-%mem | head -n5 | tr -s ' ')"
while read quentin_line
do
	echo " - ${quentin_line}"
done <<< "${a}"
echo "liste:wqning ports"
B="$(ss -ln4Hp | tr -s ' ' | cut -d' ' -f1,5,7)"
while read line
do
	tcpudp="$(tr -s ' ' <<< $line | cut -d' ' -f1)"
	ports="$(tr -s ' ' <<< $line | cut -d' ' -f2 | cut -d ':' -f2)"
	service="$(tr -s ' ' <<< $line | cut -d' ' -f3 | cut -d'"' -f2)"
	echo " - ${tcpudp} ${ports} : ${service}"
done <<< "${B}"
curl -s https://cataas.com/c > cat.jpg
echo "Here is your random cat : ./cat.jpg"
