FROM ubuntu:latest
MAINTAINER u6k <u6k.apps@gmail.com>

RUN apt-get update && \
    apt-get install -y wget build-essential

WORKDIR /usr/local/src/

RUN wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2 && \
    tar jxvf pcre-8.38.tar.bz2 && \
    cd pcre-8.38/ && \
    ./configure && \
    make && \
    make install && \
    cd ../ && \
    rm -r pcre-8.38*

RUN wget http://archive.apache.org/dist/apr/apr-1.5.2.tar.bz2 && \
    tar jxvf apr-1.5.2.tar.bz2 && \
    cd apr-1.5.2/ && \
    ./configure --prefix=/usr/local/apr-httpd/ && \
    make && \
    make install && \
    cd ../ && \
    rm -r apr-1.5.2*

RUN wget http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.bz2 && \
    tar jxvf apr-util-1.5.4.tar.bz2 && \
    cd apr-util-1.5.4/ && \
    ./configure --prefix=/usr/local/apr-util-httpd/ --with-apr=/usr/local/apr-httpd/ && \
    make && \
    make install && \
    cd ../ && \
    rm -r apr-util-1.5.4*

RUN wget http://archive.apache.org/dist/httpd/httpd-2.4.18.tar.bz2 && \
    tar jxvf httpd-2.4.18.tar.bz2 && \
    cd httpd-2.4.18/ && \
    ./configure --enable-so --with-apr=/usr/local/apr-httpd/ --with-apr-util=/usr/local/apr-util-httpd/ && \
    make && \
    make install && \
    cd ../ && \
    rm -r httpd-2.4.18* && \
    ldconfig

EXPOSE 80

RUN apt-get install -y libxml2 libxml2-dev && \
    wget -O php-7.0.4.tar.bz2 http://jp2.php.net/get/php-7.0.4.tar.bz2/from/this/mirror && \
    tar jxvf php-7.0.4.tar.bz2 && \
    cd php-7.0.4/ && \
    ./configure --enable-mbstring --with-apxs2=/usr/local/apache2/bin/apxs && \
    make && \
    make test && \
    make install && \
    cd ../ && \
    rm -r php-7.0.4*

RUN echo "Include conf/extra/php7.conf" | tee -a /usr/local/apache2/conf/httpd.conf && \
    echo "LoadModule php7_module modules/libphp7.so" | tee -a /usr/local/apache2/conf/extra/php7.conf && \
    echo "<FilesMatch \.php$>" | tee -a /usr/local/apache2/conf/extra/php7.conf && \
    echo "SetHandler application/x-httpd-php" | tee -a /usr/local/apache2/conf/extra/php7.conf && \
    echo "</FilesMatch>" | tee -a /usr/local/apache2/conf/extra/php7.conf

RUN echo "<?php phpinfo(); ?>" >/usr/local/apache2/htdocs/test.php

CMD [ "/usr/local/apache2/bin/httpd", "-DFOREGROUND" ]
