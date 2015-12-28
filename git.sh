#!/bin/sh
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker -y
yum remove git -y
###获取最新版git文件
URL="https://www.kernel.org/pub/software/scm/git"
wget $URL/$(curl -s $URL| grep -e git-[0-9].[0-9].[0-9].tar.gz |tail -1| awk -F\" '{print $2}') 
tar zxf git*.tar.gz
cd git*/
./configure
make && make install
ln -s /usr/local/bin/git /usr/bin/git
git --version
