#!/bin/bash




######### 安装 Nginx  #########
installMySQL () {
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz && tar -zxvf mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz -C /usr/local/ && rm -rf mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz && mv /usr/local/mysql-5.7.37-linux-glibc2.12-x86_64 /usr/local/mysql
#wget http://192.168.1.3/data/file/Linux/mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz && tar -zxvf mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz -C /usr/local/ && rm -rf mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz && mv /usr/local/mysql-5.7.37-linux-glibc2.12-x86_64 /usr/local/mysql

###配置
export PATH=$PATH:/usr/local/mysql/bin
groupadd mysql && useradd -r -g mysql -s /bin/false mysql
cd /usr/local/mysql/ && mkdir mysql-files
chown mysql:mysql mysql-files && chmod 750 mysql-files

###
cat >/etc/my.cnf<<-EOF
[mysqld]
#skip-grant-tables
datadir=/usr/local/mysql/data
basedir=/usr/local/mysql/
socket=/usr/local/mysql/data/mysqld.sock
user=mysql
port=3306
character-set-server=utf8
symbolic-links=0

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

[client]
socket=/usr/local/mysql/data/mysqld.sock
EOF

###
cat >/etc/systemd/system/mysql.service<<-EOF
[Unit]
Description=mysql
After=network.target
[Service]
Type=forking
ExecStart=/usr/bin/bash /usr/local/mysql/support-files/mysql.server start
ExecReload=/usr/bin/bash /usr/local/mysql/support-files/mysql.server reload
ExecStop=/usr/bin/bash /usr/local/mysql/support-files/mysql.server stop
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

###
/usr/local/mysql/bin/mysqld --initialize --user=mysql


### 
if [ $? -eq 0 ];then
	echo -e "\033[032m MySQL installd successfully !!! \033[0m";
	systemctl enable mysql
	systemctl restart mysql
	systemctl status mysql
	else
	echo -e "\033[031m MySQL installation error !!! \033[0m";
fi
}




######### 总运行 Nginx 安装程序  #########
MySQL () {
### 判断
if [ -f "/etc/lsb-release" ];then
	apt-get install libaio1 # install library
	apt install libncurses5* -y

elif [ -f "/etc/redhat-release" ]; then
 	yum -y install libaio # install library

fi

installMySQL;
}