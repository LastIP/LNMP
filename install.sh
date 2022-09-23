#!/bin/bash

### 全局变量
url="";	#用户输入的全局域名

source NginxFunctions.sh;
source MySQLFunctions.sh;
source PHPFunctions.sh;
source TrojanGoFunctions.sh;
source acmeSSLFunctions.sh;

 

echo "1. Nginx"
echo "2. PHP 8"
echo "3. MySQL"
echo "4. TrojanGo"


read -p "请输入数字: " key


case $key in
	1)	
		read -p "请输域名: " url
		Nginx 
	;;
	2)	PHP ;;
	3)	MySQL ;;
	4)	
		read -p "请输Trojan 域名: " url
		TrojanGo ;;
	# 5)	getACMESSL ;;

	10)	
	read -p "请输LNMP安装域名: " url
		Nginx
		PHP
		MySQL
		# TrojanGo
	;;

	*) 	echo -e "\033[031mSelect error !!! \033[0m" ;;
esac

