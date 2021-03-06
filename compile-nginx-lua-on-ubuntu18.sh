#!/bin/bash

# Author      : BALAJI POTHULA <balaji.pothula@techie.com>,
# Date        : 02 May 2020,
# Description : Installing / Compiling NGINX from Source Code.

# exit immediately if a command exits with a non-zero exit status.
set -e

# debugging shell script.
set -x

# update package repositories.
sudo apt -y update

# upgrading packages.
sudo apt -y upgrade

# build essentials installing.
sudo apt -y install autoconf        \
                    automake        \
                    build-essential \
                    g++             \
                    gcc             \
                    git             \
                    make

# cloning openrestry luajit2 from git and compiling.
git clone https://github.com/openresty/luajit2.git              && \
mv        $HOME/luajit2 $HOME/luajitsrc                         && \
cd        $HOME/luajitsrc                                       && \
make XCFLAGS="-DLUAJIT_ENABLE_GC64"                             && \
make install CC="gcc -m32" TARGET_SYS=Linux PREFIX=$HOME/luajit

# setting luajit library and include path.
echo "export LUAJIT_LIB=$HOME/luajit/lib"                | tee -a $HOME/.bashrc $HOME/.profile && \
echo "export LD_LIBRARY_PATH=$HOME/luajit/lib"           | tee -a $HOME/.bashrc $HOME/.profile && \
echo "export LUAJIT_INC=$HOME/luajit/include/luajit-2.1" | tee -a $HOME/.bashrc $HOME/.profile && \
source $HOME/.bashrc $HOME/.profile

# zlib downloading and extracting.
curl -JL https://zlib.net/zlib-1.2.11.tar.gz -o $HOME/zlib.tar.gz && \
tar  -xf $HOME/zlib.tar.gz -C $HOME                               && \
rm   -rf $HOME/zlib.tar.gz                                        && \
mv       $HOME/zlib-* $HOME/zlibsrc

# pcre downloading and extracting.
curl -JL https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz -o $HOME/pcre.tar.gz && \
tar  -xf $HOME/pcre.tar.gz -C $HOME                                          && \
rm   -rf $HOME/pcre.tar.gz                                                   && \
mv       $HOME/pcre-* $HOME/pcresrc

# libressl downloading and extracting.
curl -JL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.1.1.tar.gz -o $HOME/libressl.tar.gz && \
tar  -xf $HOME/libressl.tar.gz -C $HOME                                                              && \
rm   -rf $HOME/libressl.tar.gz                                                                       && \
mv       $HOME/libressl-* $HOME/libresslsrc

# nginx downloading, extracting and compiling.
curl -JL https://openresty.org/download/openresty-1.15.8.3.tar.gz -o $HOME/nginx.tar.gz         && \
tar  -xf $HOME/nginx.tar.gz -C $HOME                                                            && \
rm   -rf $HOME/nginx.tar.gz                                                                     && \
mv       $HOME/openresty-* $HOME/nginxsrc                                                       && \
cd       $HOME/nginxsrc                                                                         && \
./configure --prefix=$HOME/nginx                                                                   \
            --sbin-path=$HOME/nginx/bin/nginx                                                      \
            --conf-path=$HOME/nginx/conf/nginx.conf                                                \
            --error-log-path=$HOME/nginx/log/error.log                                             \
            --http-log-path=$HOME/nginx/log/access.log                                             \
            --pid-path=$HOME/nginx/log/nginx.pid                                                   \
            --lock-path=$HOME/nginx/log/nginx.lock                                                 \
            --http-client-body-temp-path=$HOME/nginx/client_body_temp                              \
            --http-fastcgi-temp-path=$HOME/nginx/fastcgi_temp                                      \
            --http-proxy-temp-path=$HOME/nginx/proxy_temp                                          \
            --http-scgi-temp-path=$HOME/nginx/scgi_temp                                            \
            --http-uwsgi-temp-path=$HOME/nginx/uwsgi_temp                                          \
            --user=nobody                                                                          \
            --group=nobody                                                                         \
            --build=Ubuntu                                                                         \
            --with-cpu-opt=generic                                                                 \
            --with-cc-opt='-static -static-libgcc -fPIE'                                           \
            --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-rpath,/home/ubuntu/luajit/lib' \
            --with-luajit                                                                          \
            --with-debug                                                                           \
            --with-pcre=$HOME/pcresrc                                                              \
            --with-pcre-jit                                                                        \
            --with-zlib=$HOME/zlibsrc                                                              \
            --with-openssl=$HOME/libresslsrc                                                       \
            --with-openssl-opt=enable-ec_nistp_64_gcc_128                                          \
            --with-openssl-opt=no-nextprotoneg                                                     \
            --with-openssl-opt=no-weak-ssl-ciphers                                                 \
            --with-openssl-opt=no-ssl3                                                             \
            --with-http_ssl_module                                                              && \
make                                                                                            && \
make install

echo "export PATH=$PATH:$HOME/nginx/bin:$HOME/nginx/luajit/bin" | tee -a $HOME/.bashrc $HOME/.profile
source $HOME/.bashrc $HOME/.profile

# create nginx temp folders.
mkdir -p $HOME/nginx/{client_body_temp,fastcgi_temp,proxy_temp,scgi_temp,uwsgi_temp}

# cleaning process.
rm -rf $HOME/{luajit,luajitsrc,nginxsrc,libresslsrc,pcresrc,zlibsrc}
rm -rf $HOME/nginx/{COPYRIGHT,resty.index,pod,site}
rm -v  $HOME/nginx/conf/!("nginx.conf"|"mime.types")
