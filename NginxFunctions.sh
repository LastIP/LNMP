#!/bin/bash


######### Debian 系列初始化 #########
initDebianNginx () {
apt-get update -y
apt-get install zlib1g-dev libpcre3 libpcre3-dev automake make -y
apt-get install curl gcc zip vim wget unzip build-essential libtool libssl-dev automake autoconf -y
}



######### Redhat 系列初始化  #########
initRedhatNginx () {
systemctl restart firewalld
firewall-cmd --list-all
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --reload
systemctl restart firewalld 
# systemctl stop firewalld

sed -i 's/=enforcing/=disabled/g' /etc/selinux/config;
yum install -y wget gcc gcc-c++ vim libtool zip perl-core zlib-devel wget pcre* unzip automake autoconf make curl vim
}



######### 安装 Nginx  #########
installNginx () {
if [[ $url -eq "" ]];then
    read -p "请输Nginx域名: " url
fi
    
mkdir -p /usr/local/nginx/conf.d;
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1l.tar.gz && tar xzvf openssl-1.1.1l.tar.gz;
wget https://nginx.org/download/nginx-1.18.0.tar.gz && tar xf nginx-1.18.0.tar.gz && cd nginx-1.18.0;

# wget --no-check-certificate http://192.168.1.3/data/file/Linux/openssl-1.1.1l.tar.gz && tar xzvf openssl-1.1.1l.tar.gz;
# wget http://192.168.1.3/data/file/Linux/nginx-1.18.0.tar.gz && tar xf nginx-1.18.0.tar.gz && cd nginx-1.18.0;
###
./configure --prefix=/usr/local/nginx --with-openssl=../openssl-1.1.1l --with-openssl-opt='enable-tls1_3' --with-stream_ssl_preread_module \
--with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module \
--with-http_sub_module --with-stream --with-stream_ssl_module --with-http_mp4_module --with-http_flv_module
###
make && make install;

###
getACMESSL

### Nginx 1.18 配置
cat >/usr/local/nginx/conf/nginx.conf<<-EOF

user  root;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}

stream {
  map \$ssl_preread_server_name \$backend_name {
    dns.$url trojan;
    $url html;

    default html;
  }


  upstream trojan {
    server 127.0.0.1:12311;
  }
  upstream html {
    server 127.0.0.1:12322;
  }
 

  server {
    listen 443 reuseport;
    listen [::]:443 reuseport;
    proxy_pass \$backend_name;
    ssl_preread on;
  }
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

    ###
    server {
        server_name  localhost;
        root   /usr/local/nginx/html/;
        index  index.php index.html index.htm;

        location ~ \.php\$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;

            fastcgi_connect_timeout 600s;
            fastcgi_send_timeout 600s;
            fastcgi_read_timeout 600s;
            fastcgi_buffer_size 128k;
            fastcgi_buffers 8 128k;
            fastcgi_busy_buffers_size 256k;
            fastcgi_temp_file_write_size 256k;
            fastcgi_intercept_errors on;
        }
    }


   include /usr/local/nginx/conf.d/*.conf;

}
EOF
cat >/usr/local/nginx/conf.d/$url.conf<<-EOF
server {
        listen       80;
        server_name $url;
        root   /usr/local/nginx/html/;
        index  index.php index.html;

    location / {    try_files \$uri \$uri/ /index.php?\$args;   }

    location ~ \.php\$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }


    rewrite ^(.*)\$  https://\$host\$1 permanent;
}

server {
    listen 12322 ssl http2;
    server_name $url;
    root /usr/local/nginx/html/;
    index  index.php index.html;

    ssl_certificate   /usr/local/nginx/ssl/$url/cert.pem;
    ssl_certificate_key  /usr/local/nginx/ssl/$url/key.pem;
    #TLS 版本控制
    ssl_protocols   TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;    ssl_ciphers     'TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5';
    ssl_prefer_server_ciphers   on;
    # 开启 1.3 0-RTT
    ssl_early_data  on;
    ssl_stapling on;
    ssl_stapling_verify on;
    #add_header Strict-Transport-Security "max-age=31536000";
    #access_log /var/log/nginx/access.log combined;
 
    location / {    try_files \$uri \$uri/ /index.php?\$args;   }

    location ~ \.php\$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

### php 测试
cat >/usr/local/nginx/html/t.php<<-EOF
<?php
phpinfo();
?>
EOF

if [ $? -eq 0 ];then
###
cat >/etc/systemd/system/nginx.service<<-EOF
[Unit]
Description=nginx
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

###
systemctl restart nginx.service

###
    if [ $? -eq 0 ];then
    	echo -e "\033[032m Nginx installd successfully !!! \033[0m";
        systemctl enable nginx.service
        systemctl status nginx.service
    else
    	echo -e "\033[031m Nginx installation error !!! \033[0m";
    fi
fi
}

######### 总运行 Nginx 安装程序  #########
Nginx () {
### 判断
if [ -f "/etc/lsb-release" ];then
	initDebianNginx;
elif [ -f "/etc/redhat-release" ]; then
 	initRedhatNginx;
fi

installNginx;
}