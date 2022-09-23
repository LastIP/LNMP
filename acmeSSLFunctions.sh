#!/bin/bash



#########   #########
getACMESSL () {

### 域名
if [[ $url -eq "" ]];then
	read -p "请输SSL域名: " url
fi
arr=(${url//./ });
rootUrl="${arr[-2]}.${arr[-1]}";


### 安装
if [[ ! -d "~/.acme.sh" ]]; then
	curl https://get.acme.sh | sh -s email=my@example.com

	### CF DNS API
	Token='AAAA'
	Account_ID='BBBB'
	sed -i "s/#CF_Token=\"xxxx\"/CF_Token='$Token'/g" ~/.acme.sh/dnsapi/dns_cf.sh
	sed -i "s/#CF_Account_ID=\"xxxx\"/CF_Account_ID='$Account_ID'/g" ~/.acme.sh/dnsapi/dns_cf.sh
fi

### 域名是否SSL存在
if [[ ! -d "~/.acme.sh/$rootUrl" ]]; then
	#statements


	### 
	#~/.acme.sh/acme.sh --issue --server https://acme-v02.api.letsencrypt.org/directory --dns dns_cf -d $rootUrl -d "*.$rootUrl"
	~/.acme.sh/acme.sh --issue --dns dns_cf -d $rootUrl -d "*.$rootUrl"

	### 判断域名证书是否存在
	SSLDir="/usr/local/nginx/ssl/${arr[-2]}.${arr[-1]}";
	### 
	if [[ ! -d "$SSLDir" ]]; then
		mkdir -p "$SSLDir";
	fi

	~/.acme.sh/acme.sh --install-cert -d $rootUrl \
	--key-file     /usr/local/nginx/ssl/$rootUrl/key.pem  \
	--fullchain-file /usr/local/nginx/ssl/$rootUrl/cert.pem 

else
	echo -e "\033[032m Domain name exists !!!\033[0m";

fi

}



