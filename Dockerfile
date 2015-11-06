FROM centos:7

MAINTAINER Aleksandr Lykhouzov <lykhouzov@gmail.com>

ENV container docker
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; \
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm; \
yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum install -y wget \
httpd crontabs \
php55w php55w-ftp php55w-opcache php55w-imap php55w-mysql \
php55w-curl php55w-gd php55w-mcrypt php55w-xmlrpc \
php55w-xsl php55w-pear php55w-phar php55w-posix \
php55w-soap php55w-xmlreader php55w-xmlwriter \
php55w-zlib php55w-zip php55w-dom php55w-mcrypt  \
&& /usr/bin/yum clean all \
## Install ioncube
&& curl -O http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
&& tar -zxvf ioncube_loaders_lin_x86-64.tar.gz \
&& cp ioncube/ioncube_loader_lin_5.5.so ioncube/ioncube_loader_lin_5.5_ts.so /usr/lib64/php/modules/ \
&& echo 'zend_extension=ioncube_loader_lin_5.5.so' > /etc/php.d/ioncube.ini \
&& sed -i 's/#ServerName www.example.com:80/ServerName localhost/g' /etc/httpd/conf/httpd.conf \
&& sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf \
&& systemctl enable httpd.service



VOLUME [ "/sys/fs/cgroup" ]
# ENTRYPOINT ["/usr/sbin/init"]

COPY ./php.ini /etc/
EXPOSE 80 8080
# CMD ["httpd","-DFOREGROUND"]
CMD ["/usr/sbin/init"]
