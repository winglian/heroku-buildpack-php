#!/bin/bash
set -e

mkdir /app/local
mkdir /app/local/lib
mkdir /app/local/bin
mkdir /app/local/include
mkdir /app/apache
mkdir /app/php

cd /tmp
curl -O http://mirrors.us.kernel.org/ubuntu/pool/universe/m/mcrypt/mcrypt_2.6.8-1_amd64.deb
curl -O http://mirrors.us.kernel.org/ubuntu/pool/universe/libm/libmcrypt/libmcrypt4_2.5.8-3.1_amd64.deb
curl -O http://mirrors.us.kernel.org/ubuntu/pool/universe/libm/libmcrypt/libmcrypt-dev_2.5.8-3.1_amd64.deb
ls -tr *.deb > packages.txt
while read l; do
    ar x $l
    tar -xzf data.tar.gz
    rm data.tar.gz
done < packages.txt

cp -a /tmp/usr/include/* /app/local/include
cp -a /tmp/usr/lib/* /app/local/lib

# export APACHE_MIRROR_HOST="http://www.apache.org/dist"
export APACHE_MIRROR_HOST="http://apache.mirrors.tds.net"

# curl -L ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/libmcrypt-2.5.7.tar.gz -o /tmp/libmcrypt-2.5.7.tar.gz
# curl -L ftp://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-2.1.25.tar.gz -o /tmp/cyrus-sasl-2.1.25.tar.gz
echo "downloading libmemcached"
curl -L https://launchpad.net/libmemcached/1.0/1.0.13/+download/libmemcached-1.0.13.tar.gz -o /tmp/libmemcached-1.0.13.tar.gz
echo "downloading PCRE"
curl -L ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.31.tar.gz -o /tmp/pcre-8.31.tar.gz
echo "downloading apr"
curl -L ${APACHE_MIRROR_HOST}/apr/apr-1.4.6.tar.gz -o /tmp/apr-1.4.6.tar.gz
echo "downloading apr-util"
curl -L ${APACHE_MIRROR_HOST}/apr/apr-util-1.5.1.tar.gz -o /tmp/apr-util-1.5.1.tar.gz
echo "downloading httpd"
curl -L ${APACHE_MIRROR_HOST}/httpd/httpd-2.4.3.tar.gz -o /tmp/httpd-2.4.3.tar.gz
echo "downloading php"
curl -L http://us.php.net/get/php-5.4.8.tar.gz/from/us2.php.net/mirror -o /tmp/php-5.4.8.tar.gz
echo "downloading pecl-memcached"
curl -L http://pecl.php.net/get/memcached-2.1.0.tgz -o /tmp/memcached-2.1.0.tgz

# tar -C /tmp -xzf /tmp/libmcrypt-2.5.7.tar.gz
# tar -C /tmp -xzf /tmp/cyrus-sasl-2.1.25.tar.gz
tar -C /tmp -xzf /tmp/libmemcached-1.0.13.tar.gz
tar -C /tmp -xzf /tmp/pcre-8.31.tar.gz
tar -C /tmp -xzf /tmp/httpd-2.4.3.tar.gz

tar -C /tmp/httpd-2.4.3/srclib -xzf /tmp/apr-1.4.6.tar.gz
mv /tmp/httpd-2.4.3/srclib/apr-1.4.6 /tmp/httpd-2.4.3/srclib/apr

tar -C /tmp/httpd-2.4.3/srclib -xzf /tmp/apr-util-1.5.1.tar.gz
mv /tmp/httpd-2.4.3/srclib/apr-util-1.5.1 /tmp/httpd-2.4.3/srclib/apr-util

tar -C /tmp -xzf /tmp/php-5.4.8.tar.gz
tar -C /tmp -xzf /tmp/memcached-2.1.0.tgz

export CFLAGS='-g0 -O2 -s -m64 -march=core2 -mtune=generic -pipe '
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-I/app/local/include"
export LD_LIBRARY_PATH="/app/local/lib"
export MAKEFLAGS="-j5"
export MAKE_CMD="/usr/bin/make $MAKEFLAGS"

# cd /tmp/libmcrypt-2.5.7
# ./configure --prefix=/app/local --disable-posix-threads --enable-dynamic-loading --enable-static-link
# ${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/pcre-8.31
./configure --prefix=/app/local --enable-jit --enable-utf8
${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/httpd-2.4.3
./configure --prefix=/app/apache --enable-rewrite --enable-so --enable-deflate --enable-expires --enable-headers --enable-proxy-fcgi --with-mpm=event --with-included-apr --with-pcre=/app/local
${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp
git clone git://github.com/ByteInternet/libapache-mod-fastcgi.git
cd /tmp/libapache-mod-fastcgi/
patch -p1 < debian/patches/byte-compile-against-apache24.diff 
sed -e "s%/usr/local/apache2%/app/apache%" Makefile.AP2 > Makefile
${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/php-5.4.8
./configure --prefix=/app/php --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv --with-gd --with-curl=/usr/lib --with-config-file-path=/app/php --enable-soap=shared --with-openssl --enable-mbstring --with-mhash --enable-mysqlnd --with-pear --with-mysqli=mysqlnd --with-jpeg-dir --with-png-dir --with-mcrypt=/app/local --enable-static --enable-fpm --with-pcre-dir=/app/local --disable-cgi
${MAKE_CMD}
${MAKE_CMD} install

/app/php/bin/pear config-set php_dir /app/php
echo " " | /app/php/bin/pecl install memcache
echo " " | /app/php/bin/pecl install apc-3.1.13
/app/php/bin/pecl install igbinary

# cd /tmp/cyrus-sasl-2.1.25
# ./configure --prefix=/app/local
# ${MAKE_CMD} && ${MAKE_CMD} install
# export SASL_PATH=/app/local/lib/sasl2

cd /tmp/libmemcached-1.0.13
./configure --prefix=/app/local
# the configure script detects sasl, but is still foobar'ed
# sed -i 's/LIBMEMCACHED_WITH_SASL_SUPPORT 0/LIBMEMCACHED_WITH_SASL_SUPPORT 1/' Makefile
${MAKE_CMD} && ${MAKE_CMD} install

cd /tmp/memcached-2.1.0
/app/php/bin/phpize
./configure --with-libmemcached-dir=/app/local \
  --prefix=/app/php \
  --enable-memcached-igbinary \
  --enable-memcached-json \
  --with-php-config=/app/php/bin/php-config \
  --enable-static
${MAKE_CMD} && ${MAKE_CMD} install

echo '2.4.3' > /app/apache/VERSION
echo '5.4.8' > /app/php/VERSION
mkdir /tmp/build
mkdir /tmp/build/local
mkdir /tmp/build/local/lib
mkdir /tmp/build/local/lib/sasl2
cp -a /app/apache /tmp/build/
cp -a /app/php /tmp/build/
# cp -aL /usr/lib/libmysqlclient.so.16 /tmp/build/local/lib/
# cp -aL /app/local/lib/libhashkit.so.2 /tmp/build/local/lib/
cp -aL /app/local/lib/libmcrypt.so.4 /tmp/build/local/lib/
cp -aL /app/local/lib/libmemcached.so.11 /tmp/build/local/lib/
cp -aL /app/local/lib/libpcre.so.1 /tmp/build/local/lib/
# cp -aL /app/local/lib/libmemcachedprotocol.so.0 /tmp/build/local/lib/
# cp -aL /app/local/lib/libmemcachedutil.so.2 /tmp/build/local/lib/
# cp -aL /app/local/lib/sasl2/*.so.2 /tmp/build/local/lib/sasl2/

rm -rf /tmp/build/apache/manual/

