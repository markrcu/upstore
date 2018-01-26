FROM centos:6

#=========================================================
# Build a deployable Native Php 5.2 site container
# Container: Php5.2
# PHP Version: 5.2
# Apache Version: 2.2
#=========================================================

MAINTAINER sysops@digitalroominc.com

# --------------------------------------------------------
# Add/Install Compile Tools
# --------------------------------------------------------

RUN yum groupinstall -y 'Development Tools'
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install gcc \
            gcc-c++ \
            autoconf \
            automake \
            make

RUN yum clean all

# --------------------------------------------------------
# Add/Install Dependencies
# --------------------------------------------------------

RUN yum -y install zlib-devel \
            pkgconfig \
            openssl-devel  \
            keyutils-libs-devel  \
            krb5-devel  \
            libcom_err-devel  \
            libselinux-devel  \
            libsepol-devel  \
            libxml2-devel  \
            bzip2-devel  \
            libcurl-devel  \
            libidn-devel  \
            freetype-devel  \
            libjpeg-devel  \
            libpng-devel  \
            freetype  \
            mysql  \
            mysql-devel  \
            libmcrypt-devel  \
            libmcrypt  \
            libjpeg  \
            libjpeg-devel  \
            GeoIP-devel  \
            libevent-devel  \
            libtool-ltdl-devel  \
            nawk  \
            file-devel  \
            lcms2  \
            lcms2-devel  \
            lcms2-utils  \
            libwmf  \
            libwmf-devel  \
            libwmf-lite  \
            fontconfig  \
            fontconfig-devel  \
            ghostscript  \
            ghostscript-devel  \
            libtiff  \
            libtiff-devel \
            wget

RUN yum clean all

# --------------------------------------------------------
# Add/Install softwares necessary for deployment
# -------------------------------------------------------- 

RUN yum -y install nfs-utils \
            unzip \
            python-devel \
            python-pip \
            lxml \
            mysql \
            postfix \
            mailx \
            telnet \
            curl \
            cloud-init \
            dmidecode \
            ntp 

RUN yum clean all

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install awscli

#COPY ./common/postfix-config/master.cf /etc/postfix/master.cf
#COPY ./common/postfix-config/main.cf /etc/postfix/main.cf
#COPY ./common/cloud-init/cloud.cfg /etc/cloud/cloud.cfg
    
RUN chkconfig postfix on  && \
    chkconfig cloud-config on && \
    chkconfig cloud-final on && \
    chkconfig cloud-init on && \
    chkconfig cloud-init on && \
    chkconfig cloud-init-local on

# --------------------------------------------------------
# Install rkhunter
# --------------------------------------------------------

RUN mkdir /opt/installer && \ 
    cd /opt/installer && \
    wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/rkhunter-1.4.0.tar.gz && \
    tar -xvf rkhunter-1.4.0.tar.gz && \
    cd rkhunter-1.4.0 && \
    ./installer.sh --layout default --install 

# --------------------------------------------------------
# Install libmemcached
# --------------------------------------------------------

RUN mkdir -p /opt/installer && \
    cd /opt/installer && \
    wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/libmemcached-1.0.7.tar.gz && \
    tar zxvf libmemcached-1.0.7.tar.gz && \
    cd libmemcached-1.0.7 && \
    ./configure --with-libevent && \
    make && \
    make install

# --------------------------------------------------------
# Add/Install Apache
# --------------------------------------------------------

RUN groupadd apboss
RUN useradd -g apboss apboss
RUN cd /opt/installer && \
        wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/httpd-2.2.22.tar.gz && \
        tar zxvf httpd-2.2.22.tar.gz && \
        cd httpd-2.2.22 && \
        "./configure" \
            "--prefix=/usr/local/apache2" \
            "--enable-so" \
            "--enable-rewrite" \
            "--enable-speling" \
            "--enable-usertrack" \
            "--enable-deflate" \
            "--enable-ssl" \
            "--enable-mime-magic" \
            "--enable-auth-digest" \
            "--enable-expires" \
            "--enable-setenvif" \
            "--enable-mime" \
            "--with-ssl" \
            "--enable-headers" \
            "--enable-cgi" \
            "--enable-suexec" \
            "--enable-info" \
            "--with-included-apr" \
            "--with-mpm=prefork" \
            "--enable-cache" \
            "--enable-mem-cache" \
            "--enable-proxy" \
            "--enable-proxy-html" \
            "--enable-proxy-http" \
            "--enable-mods-shared=proxy proxy_http proxy_ftp proxy_connect" && \
        make && \
        make install

RUN mkdir /usr/local/apache2/conf/vhosts && \
    mkdir /usr/local/apache2/conf/ssl.key && \
    mkdir /usr/local/apache2/conf/ssl.crt && \
    mkdir /usr/local/apache2/conf/rewriterules && \
    mkdir /home/apache2 && \ 
    mkdir /home/apache2/test

COPY ./apache-config/httpd /etc/init.d/httpd
COPY ./apache-config/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./apache-config/httpd-mpm.conf /usr/local/apache2/conf/extra/httpd-mpm.conf

RUN chmod a+x /etc/init.d/httpd && \
    chmod a+x /usr/local/apache2/conf/httpd.conf && \
    chmod a+x /usr/local/apache2/conf/extra/httpd-mpm.conf && \ 
    chmod a+x /usr/local/apache2/conf/vhosts/

RUN chown root:root /etc/init.d/httpd && \
    chown root:root /usr/local/apache2/conf/httpd.conf && \
    chown root:root /usr/local/apache2/conf/extra/httpd-mpm.conf && \
    chown root:root /usr/local/apache2/conf/vhosts/

RUN chkconfig httpd on

# --------------------------------------------------------
# Add/Install PHP and extensions, modules
# --------------------------------------------------------

RUN yum -y install libc-client-devel
RUN cd /opt/installer && \
    wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/php-5.2.17.tar.gz && \
    tar zxvf php-5.2.17.tar.gz && \
    cd php-5.2.17 && \
    ./configure \
		--with-apxs2=/usr/local/apache2/bin/apxs \
		--with-config-file-path=/usr/local/apache2/conf \
		--with-mysql=/usr/bin/mysql \
		--with-mysql-sock=/var/lib/mysql/mysql.sock \
		--with-mysqli=/usr/bin/mysql_config \
		--with-cpdflib=/usr/local \
		--with-freetype-dir=/usr \
		--with-jpeg-dir=/usr/lib64/libjpeg.so \
		--with-png-dir=/usr/lib64/libpng.so \
		--with-gettext \
		--with-zlib \
		--with-zlib-dir \
		--with-bz2 \
		--with-ttf \
		--with-curl \
		--with-imagemagick \
		--with-mcrypt \
		--enable-inline-optimization \
		--enable-track-vars \
		--enable-gd \
		--enable-gd-native-ttf \
		--enable-trans-id \
		--enable-ftp \
		--enable-mbstring \
		--enable-exif \
		--with-openssl \
		--disable-ipv6 \
		--disable-debug \
		--disable-static \
		--enable-soap \
		--with-mime-magic \
		--enable-mime-magic \
		--with-gd \
		--with-libdir=lib64 \
		--with-pdo-mysql \
		--with-imap-ssl=/usr/local/imap-2007f \
		--with-imap=/usr/local/imap-2007f \
		--with-kerberos && \	
	make && \
    make install 

RUN mkdir /usr/lib/php && \
    mkdir /usr/lib/php/modules && \
    mv /usr/share/magic /usr/share/magic.bak

COPY ./php-config/magic /usr/share/magic 
COPY ./php-config/php.ini /usr/local/apache2/conf/php.ini

RUN echo "<?php phpinfo(); ?>" > /usr/local/apache2/htdocs/info.php

# --------------------------------------------------------
# Add/Install additional php modules
# --------------------------------------------------------

RUN pecl install apc && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/apc.so /usr/lib/php/modules/ 

RUN pecl install GeoIP && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/geoip.so /usr/lib/php/modules/

RUN pecl install memcache && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/memcache.so /usr/lib/php/modules/

RUN	pecl install memcached-1.0.1 && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/memcached.so /usr/lib/php/modules/

RUN yum -y install libssh2 libssh2-devel && \
    pecl install ssh2-beta && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/ssh2.so /usr/lib/php/modules/

RUN pecl -d preferred_state=stable install -a zip-1.13.5 && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/zip.so /usr/lib/php/modules/

RUN cd /opt/installer/ && \
    wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/ImageMagick-6.7.2-9.tar.gz && \
    tar zxvf ImageMagick-6.7.2-9.tar.gz && \
    cd ImageMagick-6.7.2-9 && \
    ./configure --disable-openmp && \
    make && \
    make install && \
    pecl install imagick-2.2.2 && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/imagick.so /usr/lib/php/modules/

RUN yum -y install pam-devel libc-client libc-client-devel && \
    cd /opt/installer && \
    wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/imap-2007f.tar.gz && \
    tar xzpf imap-2007f.tar.gz && \
    cd imap-2007f && \
    sed -i -e 's~^EXTRACFLAGS=$~EXTRACFLAGS=-fpic~g' Makefile && \
    make lfd PASSWDTYPE=std SSLTYPE=unix.nopwd IP6=4 && \
    mkdir /usr/local/imap-2007f && \
    mkdir /usr/local/imap-2007f/include/ && \
    mkdir /usr/local/imap-2007f/lib64/ && \
    cp -pr c-client/c-client.a /usr/local/imap-2007f/lib64/libc-client.a && \
    chmod -R 077 /usr/local/imap-2007f && \
    cp -pr imapd/imapd /usr/sbin/ && \
    cp -pr c-client/*.h /usr/local/imap-2007f/include/ && \
    cp -pr c-client/*.c /usr/local/imap-2007f/lib64/ && \
    cp -pr c-client/c-client.a /usr/local/imap-2007f/lib64/libc-client.a

RUN cd /opt/installer && \
    pecl download fileinfo && \
    tar zxvf Fileinfo-1.0.4.tgz && \
    cd Fileinfo-1.0.4 && \
    phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config && \
    make && \
    make install && \
    cp -pr /usr/local/lib/php/extensions/no-debug-non-zts-20060613/fileinfo.so /usr/lib/php/modules/

# --------------------------------------------------------
# Add/Install LibPDF
# --------------------------------------------------------

RUN cd /opt/installer && \
    wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/PDFlib-8.0.4p1-Linux-x86_64-php.tar.gz && \
    tar zxvf PDFlib-8.0.4p1-Linux-x86_64-php.tar.gz && \
    cd PDFlib-8.0.4p1-Linux-x86_64-php && \
    cp -pr bind/php/php-520/libpdf_php.so /usr/lib/php/modules/libpdf8.so && \
    cd /opt/installer && \
    mkdir /usr/local/PDFlib 

#COPY ./common/pdflib-lic/licensekeys.txt /usr/local/PDFlib/licensekeys.txt

# --------------------------------------------------------
# Add/Install SWFTools
# --------------------------------------------------------

RUN cd /opt/installer && \
    wget https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/swftools-0.9.1.tar.gz && \
    tar xzpf swftools-0.9.1.tar.gz && \
    cd swftools-0.9.1 && \
    ./configure && \
    make && \
    make install

# --------------------------------------------------------
# Update LibCurl version
# --------------------------------------------------------
 
RUN rpm -Uvh https://s3-ap-southeast-1.amazonaws.com/sg-digitalroom-tools/server-provisioning/installers/city-fan.org-release-1-13.rhel6.noarch.rpm
RUN yum -y update curl && \
    yum clean all

# --------------------------------------------------------
# Set server time to America/Los_Angeles
# --------------------------------------------------------

RUN sed -i -e 's~^;date.timezone =$~date.timezone = America/Los_Angeles~g' /usr/local/apache2/conf/php.ini && \
    mv /etc/localtime /etc/localtime.default && \
    ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime 

# --------------------------------------------------------
# Add Rewrites
# --------------------------------------------------------

ENV	DIR_DOMAIN=store.uprinting.com
RUN     mkdir -p /mnt/phpcatalogs/${DIR_DOMAIN}/public && \
        echo "<?php phpinfo(); ?>" > /mnt/phpcatalogs/${DIR_DOMAIN}/public/info.php 

ADD	certs/UP.crt /usr/local/apache2/conf/ssl.crt/UP.crt
ADD	certs/UP.key /usr/local/apache2/conf/ssl.key/UP.key
ADD	certs/CA.txt /usr/local/apache2/conf/ssl.crt/CA.txt

ADD     conf/UP3-301-rules.conf /usr/local/apache2/conf/vhosts/UP3-301-rules.conf
ADD     conf/store-uprinting-com.conf /usr/local/apache2/conf/vhosts/0000-store-uprinting-com.conf

# --------------------------------------------------------
# Create script entrypoint
# --------------------------------------------------------

RUN     echo -e '#!/bin/sh \nsh /etc/init.d/httpd restart \
        \necho "export DOMAIN_NAME='\$DOMAIN_NAME'" >> /etc/environment \
        \necho "export DOMAIN_STORE='\$DOMAIN_STORE'" >> /etc/environment \
        \necho "export DOMAIN_PAYMENT='\$DOMAIN_PAYMENT'" >> /etc/environment \
        \necho "export DOMAIN_DESIGN='\$DOMAIN_DESIGN'" >> /etc/environment \
        \necho "export APP_SITE_ENV='\$APP_SITE_ENV'" >> /etc/environment \
        \necho "export APPLICATION_ENV='\$APPLICATION_ENV'" >> /etc/environment \
        \necho "export CALC_ENV='\$CALC_ENV'" >> /etc/environment \
        \nexec "$@"' > start.sh && \
        chmod 755 /start.sh

# --------------------------------------------------------
# COMMAND
# --------------------------------------------------------

CMD /start.sh /sbin/init
