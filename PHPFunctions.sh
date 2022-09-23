#!/bin/bash


######### 安装 PHP  #########
installPHP () {
###
groupadd www && useradd -g www www
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
cp php.ini-production /usr/local/php/etc/php.ini


### 启动配置
cat >/etc/systemd/system/php-fpm.service<<-EOF
[Unit]
Description=php-fpm
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/php/sbin/php-fpm
ExecReload=/usr/bin/killall /usr/local/php/sbin/php-fpm && /usr/local/php/sbin/php-fpm
ExecStop=/usr/bin/killall /usr/local/php/sbin/php-fpm
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF


###
systemctl restart php-fpm.service
systemctl status php-fpm.service

###
if [ $? -eq 0 ];then
	echo -e "\033[032m PHP installd successfully !!! \033[0m";
	systemctl enable php-fpm.service
else
	echo -e "\033[031m PHP installation error !!! \033[0m";
fi
}



######### Ubuntu 22 初始化 PHP 8 #########
initMint21PHP8 () {
apt-get update
apt install -y libxml2-dev libxml2 curl make gcc libssl-dev libsqlite3-dev libonig-dev libzip-dev libssl-dev pkg-config libsasl2-dev automake libcurl4-openssl-dev 
apt install -y libcurl4-gnutls-dev pkg-config

###
#wget http://192.168.1.3/data/file/Linux/php-8.1.10.tar.gz && tar -zxvf php-8.1.10.tar.gz && cd php-8.1.10
wget https://www.php.net/distributions/php-8.1.10.tar.gz && tar -zxvf php-8.1.10.tar.gz && cd php-8.1.10
./configure --prefix=/usr/local/php --with-openssl --enable-zip --with-zlib --disable-fileinfo --with-fpm-user=www --with-fpm-group=www --with-curl \
--enable-ftp --with-gettext --enable-mbregex --enable-inline-optimization --disable-rpath --enable-shared --enable-shmop --with-freetype-dir=/usr/local/freetype \
--with-jpeg-dir --enable-opcache --enable-fpm --enable-session --enable-sockets --enable-soap --without-pear --disable-debug --enable-mbstring \
--with-xmlrpc --enable-fast-install --with-mysqli --with-iconv  --enable-bcmath --with-gd --enable-inline-optimization --enable-xml \
--with-mhash  --enable-sysvsem --with-gettext --enable-pcntl --enable-maintainer-zts  --with-pdo-mysql --with-png-dir --without-gdbm --enable-fast-install

make && make install

### 调用php配置函数
installPHP
}



######### Rocky linux 8 & PHP 8  ######### https://zach.vip/server/%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85php7-4/
initRocky8PHP8 () {
yum install -y epel-release gcc gcc-c++ libxml2 libxml2-devel openssl openssl-devel sqlite-devel libcurl-devel autoconf automake libtool libxml2-devel
dnf --enablerepo=powertools install oniguruma-devel -y


#wget http://192.168.1.3/data/file/Linux/php-8.1.10.tar.gz && tar -zxvf php-8.1.10.tar.gz && cd php-8.1.10
wget https://www.php.net/distributions/php-8.1.10.tar.gz && tar -zxvf php-8.1.10.tar.gz && cd php-8.1.10
./configure --prefix=/usr/local/php --with-openssl --enable-zip --with-zlib --disable-fileinfo --with-fpm-user=www --with-fpm-group=www --with-curl \
--enable-ftp --with-gettext --enable-mbregex --enable-inline-optimization --disable-rpath --enable-shared --enable-shmop --with-freetype-dir=/usr/local/freetype \
--with-jpeg-dir --enable-opcache --enable-fpm --enable-session --enable-sockets --enable-soap --without-pear --disable-debug --enable-mbstring \
--with-xmlrpc --enable-fast-install --with-mysqli --with-iconv --enable-xml --enable-bcmath --with-gd --enable-inline-optimization \
--with-mhash  --enable-sysvsem --with-gettext --enable-pcntl --enable-maintainer-zts  --with-pdo-mysql --with-png-dir --without-gdbm --enable-fast-install
make && make install

### 调用php配置函数
installPHP
}

#################### CentOS 7 & PHP7.4
initCentOS7PHP74 () {
yum install -y epel-release libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel \
freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel zlib zlib-devel glibc \
glibc-devel glib2 glib2-devel ncurses curl gdbm-devel db4-devel libXpm-devel libX11-devel gd-devel gmp-devel expat-devel xmlrpc-c xmlrpc-c-devel \
libicu-devel libmcrypt-devel libmemcached-devel sqlite-devel oniguruma-devel

wget https://www.php.net/distributions/php-7.4.30.tar.gz && tar -zxvf php-7.4.30.tar.gz && cd php-7.4.30
./configure --prefix=/usr/local/php --with-openssl --enable-zip --with-zlib --disable-fileinfo --with-fpm-user=www --with-fpm-group=www --with-curl \
--enable-ftp --with-gettext --enable-mbregex --enable-inline-optimization --disable-rpath --enable-shared --enable-shmop --with-freetype-dir=/usr/local/freetype \
--with-jpeg-dir --enable-opcache --enable-fpm --enable-session --enable-sockets --enable-soap --without-pear --disable-debug --enable-mbstring \
--with-xmlrpc --enable-fast-install --with-mysqli --with-iconv --enable-xml --enable-bcmath --with-gd --enable-inline-optimization \
--with-mhash  --enable-sysvsem --with-gettext --enable-pcntl --enable-maintainer-zts  --with-pdo-mysql --with-png-dir --without-gdbm --enable-fast-install
make && make install

### 调用php配置函数
installPHP
}


######### 总运行 PHP 安装程序  #########
PHP () {

### Mint 21 OK
if [[ $(cat /etc/os-release | grep -n "Linux Mint 21") != "" ]];then
	initMint21PHP8;

### Rocky 8 OK
elif [[ $(cat /etc/os-release | grep -n "Rocky Linux 8") != "" || $(cat /etc/os-release | grep -n "Rocky Linux 9") != "" ]];then
	initRocky8PHP8;
	#echo 9;

### CentOS 7 OK
elif [[ $(cat /etc/os-release | grep -n "CentOS Linux 7") != "" ]];then        
	initCentOS7PHP74;

fi



}