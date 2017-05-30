# Dockerfile for a simple Nginx stream replicator

# Software versions
FROM alpine:3.4
ENV NGINX_VERSION nginx-1.13.0
ENV NGINX_RTMP_MODULE_VERSION 1.1.7.10

# Install prerequisites and update certificates
RUN apt-get install build-essential libpcre3 libpcre3-dev libssl-dev unzip

# Download the RTMP module
RUN mkdir -p /HLS && \
    mkdir -p /HLS/live && \
    mkdir -p /HLS/mobile && \
    mkdir -p /video_recordings && \
    chmod -R 777 /video_recordings

# Download the RTMP module
RUN mkdir -p /tmp/build/nginx-rtmp-module && \
    cd /tmp/build/nginx-rtmp-module && \
    wget https://github.com/arut/nginx-rtmp-module/archive/master.zip && \
    unzip master.zip


# Download nginx
RUN mkdir -p /tmp/build/nginx && \
    cd /tmp/build/nginx && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz


# Build and install nginx
RUN cd /tmp/build/nginx/${NGINX_VERSION} && \
     ./configure --with-http_ssl_module --with-http_stub_status_module --add-module=../../nginx-rtmp-module/nginx-rtmp-module-master \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install

RUN mkdir -p /tmp/build/extras && \
    cd /tmp/build/extras && \
    wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx && \
    chmod +x /etc/init.d/nginx && \
    update-rc.d nginx defaults && \
    rm -rf /tmp/build

RUN service nginx start && \
    service nginx stop 

RUN apt-get install software-properties-common && \
    add-apt-repository ppa:kirillshkrogalev/ffmpeg-next && \
    apt-get update && \
    apt-get install ffmpeg


# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Set up config file
COPY nginx.conf /etc/nginx/nginx.conf

# Set permissions
#RUN chmod 444 /etc/nginx/nginx.conf && \
#    chown ${USER}:${USER} /var/log/nginx /var/run/nginx /var/lock/nginx /tmp/nginx-client-body && \
#    chmod -R 770 /var/log/nginx /var/run/nginx /var/lock/nginx /tmp/nginx-client-body


RUN service nginx restart

# Run the application
# USER ${USER}
EXPOSE 1935 80 443 22
# CMD ["nginx", "-g", "daemon off;"]
