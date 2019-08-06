FROM centos:latest

MAINTAINER "bvisible" <info@bvisible.ch>

ENV container docker

# UPDATE
RUN yum -y install epel-release wget
RUN yum -y update
RUN rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm

#Install Proftpd
RUN yum -y install proftpd
RUN sed -i "s/ProFTPD server/$HOSTNAME/g" /etc/proftpd.conf

#Install Openlitespeed
RUN mkdir /home/defdomain
RUN mkdir /home/defdomain/html
RUN mkdir /home/defdomain/logs

RUN yum -y install openlitespeed

#Install MariaDB
ADD repo/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum -y install MariaDB-server MariaDB-client

# Install PHP 72
RUN yum -y install lsphp72 lsphp72-common lsphp72-mysqlnd lsphp72-process lsphp72-gd lsphp72-mbstring lsphp72-mcrypt lsphp72-opcache lsphp72-bcmath lsphp72-pdo lsphp72-xml lsphp72-json lsphp72-zip lsphp72-xmlrpc lsphp72-pecl-mcrypt
RUN yum -y install epel-release
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum -y install yum-utils
RUN yum-config-manager --enable remi-php72
RUN yum -y update 
RUN yum -y install php72
RUN yum -y install php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache
RUN yum --enablerepo=remi-php72 install -y php-xml php-soap php-xmlrpc php-mbstring php-json php-gd php-mcrypt
RUN yum -y install php-mysql

#Install node.js and npm
RUN yum -y install gcc-c++ make
RUN curl -sL https://rpm.nodesource.com/setup_10.x
RUN yum -y install nodejs

#Install nano
RUN yum -y install nano

#Install php-cli
RUN yum -y install php-cli php-zip wget unzip

#Install dev tools for openlitespeed
RUN yum groupinstall -y "Development Tools"
RUN yum -y install libxml2-devel openssl-devel curl-devel libpng* 

#Setting Up
RUN mv -f /usr/local/lsws/conf/vhosts/Example/ /usr/local/lsws/conf/vhosts/defdomain/
RUN rm -f /usr/local/lsws/conf/vhosts/defdomain/vhconf.conf
RUN rm -f /usr/local/lsws/conf/httpd_config.conf
RUN rm -f /usr/local/lsws/admin/conf/admin_config.conf

ADD conf/vhconf.conf /usr/local/lsws/conf/vhosts/defdomain/vhconf.conf
ADD conf/httpd_config.conf /usr/local/lsws/conf/httpd_config.conf
ADD conf/admin_config.conf /usr/local/lsws/admin/conf/admin_config.conf

RUN chown lsadm:lsadm /usr/local/lsws/conf/vhosts/defdomain/vhconf.conf
RUN chown lsadm:lsadm /usr/local/lsws/conf/httpd_config.conf
RUN chown lsadm:lsadm /usr/local/lsws/admin/conf/admin_config.conf

# make sure firewall
EXPOSE 21
EXPOSE 80
EXPOSE 443
EXPOSE 7080

COPY run.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh
RUN run.sh
RUN systemctl enable proftpd
CMD ["/usr/sbin/init"]
ENTRYPOINT /usr/local/lsws/bin/lswsctrl start && /etc/init.d/mysql start && /bin/bash

