#!/bin/bash


apt-get -y install build-essential libpcre3 libpcre3-dev libssl-dev unzip

mkdir /HLS
mkdir /HLS/live
mkdir /HLS/mobile
mkdir /video_recordings
chmod -R 777 /video_recordings

mkdir ~/working
cd ~/working

wget https://github.com/arut/nginx-rtmp-module/archive/master.zip
unzip master.zip

wget http://nginx.org/download/nginx-1.13.1.tar.gz
tar -zxvf nginx-1.13.1.tar.gz

cd nginx-1.13.1
./configure --with-http_ssl_module --with-http_stub_status_module --add-module=../nginx-rtmp-module-master

make
make install

wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
chmod +x /etc/init.d/nginx
update-rc.d nginx defaults

service nginx start
service nginx stop

apt-get -y install software-properties-common
add-apt-repository ppa:kirillshkrogalev/ffmpeg-next -y
apt-get update
apt-get -y install ffmpeg

cd ~

cp nginx.conf /usr/local/nginx/conf/nginx.conf

service nginx restart
