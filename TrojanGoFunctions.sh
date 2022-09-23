#!/bin/bash



######### 安装 Trojan-Go  #########
installTrojanGo () {
	####
	pass=$(cat /proc/sys/kernel/random/uuid);
	#url="dns.qiqiqing.com";
	arr=(${url//./ });
	confDir="\/usr\/local\/nginx\/ssl\/${arr[-2]}.${arr[-1]}";
	SSLDir="/usr/local/nginx/ssl/${arr[-2]}.${arr[-1]}";
	### 判断域名证书是否存在
	if [[ ! -d "$SSLDir" ]]; then
		mkdir -p "$SSLDir";
	fi
	### 获取证书
	getACMESSL

	wget --no-check-certificate https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip
	#wwget http://192.168.1.3/data/file/Linux/trojan-go-linux-amd64.zip
	### 判断是否安装过trojan
	if [ -d "/usr/local/trojan" ]; then
		rm -rf /usr/local/trojan/*
	else
		mkdir /usr/local/trojan
	fi
	unzip trojan-go-linux-amd64.zip -d /usr/local/trojan/ 

	rsync -av /usr/local/trojan/example/*.json /usr/local/trojan/ && cp /usr/local/trojan/example/trojan-go.service /usr/local/trojan/trojan.service
	
 	### 客户端
	sed -i "s/127.0.0.1/0.0.0.0/g" /usr/local/trojan/client.json
	sed -i "s/your_server/$url/g" /usr/local/trojan/client.json
	sed -i "s/your-domain-name.com/$url/g" /usr/local/trojan/client.json
	sed -i "s/your_password/$pass/g" /usr/local/trojan/client.json
	sed -i "s/\/usr\/share\/trojan-go\//\/usr\/local\/trojan\//g" /usr/local/trojan/client.json
	### 服务端
	sed -i "s/your_password/$pass/g" /usr/local/trojan/server.json
	sed -i "s/your_server/$url/g" /usr/local/trojan/server.json
	sed -i "s/your-domain-name.com/$url/g" /usr/local/trojan/server.json
	sed -i "s/\/usr\/share\/trojan-go\//\/usr\/local\/trojan\//g" /usr/local/trojan/server.json
	sed -i "s/your_cert.crt/$confDir\/cert.pem/g" /usr/local/trojan/server.json
	sed -i "s/your_key.key/$confDir\/key.pem/g" /usr/local/trojan/server.json
	sed -i "s/443,/12311,/g" /usr/local/trojan/server.json

	###
	sed -i "s/User=nobody/User=root/g" /usr/local/trojan/trojan.service
	sed -i '/ExecStart/c\ExecStart=\/usr\/local\/trojan\/trojan-go -config \/usr\/local\/trojan\/server.json' /usr/local/trojan/trojan.service
	rsync -av /usr/local/trojan/trojan.service /etc/systemd/system/

	###
	sleep 1
	###
	systemctl restart trojan.service
	systemctl enable trojan.service
	systemctl status trojan.service
# ###
# if [ $? -eq 0 ];then
# 	echo -e "\033[032m Trojan installd successfully !!! \033[0m";
# 	systemctl restart trojan.service
# 	systemctl enable trojan.service
# 	systemctl status trojan.service
# else
# 	echo -e "\033[031m Trojan installation error !!! \033[0m";
# fi
}



######### 总运行 Trojan-Go 安装程序  #########
TrojanGo () {
### 判断
if [ -f "/etc/lsb-release" ];then
	apt update -y
	apt install unzip -y

elif [ -f "/etc/redhat-release" ]; then
	yum install -y unzip 

fi

installTrojanGo;
}