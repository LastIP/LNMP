#!/bin/bash




linuxSystemInit () {
	if [[ ! -d ~/.ssh ]]; then
		mkdir ~/.ssh
	fi

###### .ssh
cat >~/.ssh/authorized_keys<<-EOF

ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0h+dICB6nisyYEZ9WbgzUpUBH26uifvd0QZ5+OtfKUHDDa7RkXNWzafsIm4ulAzaGNk6e8Y0O9xmESaXzh/bqkEZE4uokjAP7lEalUFSWoKSPrIf3nymWbZeXtB8OjbH1O7ekfDyj842CLewo+Y2nK37f7qXpFC4snS27KS0kEuDDl3RFSRqo/cb/S03glQByxavfADqzJyYUYzFgVXBvNN2xVsVGDj1D2j1PAVSDuRt0lky4Uc8+nncjKqF9mB0/Fe8kAmblMB3ctJ8Wlyn1/E17cvomiLhkEToRO4WvvpxbHe5Ld3v+ahCFdJl6oghsBypQU/OQMCZdVrR2w5xtQ== root@host.localdomain	
EOF
cat >~/.ssh/id_rsa<<-EOF

-----BEGIN OPENSSH PRIVATE KEY-----
-----END OPENSSH PRIVATE KEY-----

EOF
cat >~/.ssh/config<<-EOF
###
Host github.com
ProxyCommand nc -X 5 -x 127.0.0.1:1080 %h %p
#ProxyCommand ncat --proxy-type socks5 --proxy 127.0.0.1:1080 %h %p
ServerAliveInterval 10
EOF
chmod 600 ~/.ssh/authorized_keys -R
chmod 600 ~/.ssh/id_rsa -R
chmod 600 ~/.ssh/config -R

# ### 判断
if [ -f "/etc/lsb-release" ];then
	apt-get update -y
	apt-get install git openssh-server wget tsocks ffmpeg mediainfo -y

	git config --global user.name "yk"    ###设置用户名
	git config --global user.email "123@gmail.com"    ###设置邮箱
	ssh -T -p 22 git@github.com -i ~/.ssh/id_rsa    ###测试
elif [ -f "/etc/redhat-release" ]; then
 	yum install -y openssh-server wget
fi



# ### ssh
sed -i '/PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config
systemctl restart sshd
systemctl status sshd


}
