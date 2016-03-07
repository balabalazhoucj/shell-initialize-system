echo "nameserver 221.228.255.1" > /etc/resolv.conf
#更改源
yum install wget -y
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
cd /etc/yum.repos.d
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
mv CentOS6-Base-163.repo CentOS-Base.repo
#安装epel源
rpm -Uvh http://ftp.sjtu.edu.cn/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

#安装软件
yum install lrzsz gcc sysstat ntp openssh-clients lsof man tree parted vim -y
yum groupinstall "Development tools" -y

#禁用selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#时间同步
echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com > /dev/null 2>&1' >> /var/spool/cron/root

#调整文件描述符大小
echo '*       -       nofile  65536' >> /etc/security/limits.conf

#解决nfs启动过程中访问ipv6
if [ `awk '{print $3}' /etc/redhat-release` = 6.5 ];then
	sed -i "s/udp6/#udp6/" /etc/netconfig
	sed -i "s/tcp6/#tcp6/" /etc/netconfig
fi

VER=$(sed 's/[^0-9]*\([0-9]\).*/\1/p' /etc/redhat-release)

if [ $VER = 7 ];then
	#禁用firewalld
	systemctl stop firewalld
	systemctl disable firewalld	
	#安装iptables
	yum install iptables-services -y
	#修改网卡名
	grep "GRUB_CMDLINE_LINUX" /etc/sysconfig/grub | sed -i 's/quiet"/quiet net.ifnames=0 biosdevname=0"/'
	grub2-mkconfig -o /boot/grub2/grub.cfg
	#禁用ipv6
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.d/99-sysctl.conf
	#生成网卡
	cat < /etc/sysconfig/network-scripts/ifcfg-eth0 >EOF
	DEVICE=eth0
	HWADDR=52:54:00:38:DF:2E
	IPADDR=10.9.43.140
	NETMASK=255.255.0.0
	GATEWAY=10.9.0.1
	BOOTPROTO=static
	PEERDNS=yes
	USERCTL=no
	NM_CONTROLLED=no
	ONBOOT=yes
	MTU=1454
	DNS1=114.114.114.114
	EOF
fi

if [ $VER = 6 ];then
	#精简开机自动启动项
	for a in `chkconfig --list | grep 3:on|awk '{print $1}'`;do chkconfig --level 3 $a off;done
	for a in crond network rsyslog sshd sysstat;do chkconfig --level 3 $a on;done 
	#禁用I
	echo -ne "alias net-pf-10 off\noptions ipv6 disable=1" > /etc/modprobe.d/ipv6off.conf
fi

#添加普通用户并进行sudo授权管理
useradd zhoucj
echo "123456"|passwd --stdin zhoucj&&history –c
echo "zhoucj  ALL=(ALL)       ALL" >> /etc/sudoers

echo "alias vi='vim'" >> /etc/profile
echo "alias grep='grep --colour'" >> /etc/profile

#定义命令行提示符，能够显示当前目录，并且输入命令的地方单独一行
export PS1='\n\e[1;37m[\e[m\e[1;32m\u\e[m\e[1;33m@\e[m\e[1;35m\H\e[m \e[4m`pwd`\e[m\e[1;37m]\e[m\e[1;36m\e[m\n\$'

#定义编辑器格式
cat > .vimrc <<EOF
set ts=4
set fencs=utf-8
set t_Co=256
syntax on
EOF
