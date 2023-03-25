FROM debian:11-slim

# 设置工作目录
WORKDIR /tmp

# 定义 Nginx 版本和 ngx_http_proxy_connect_module 版本
ARG NGINX_VERSION=1.22.1 

# 安装必要的软件包、下载 Nginx 和 ngx_http_proxy_connect_module 源码
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential unzip \
        ca-certificates \
        curl \
        gnupg2 \
        libpcre3-dev \
        libssl-dev \
        zlib1g-dev \
        inetutils-ping \
        telnet && \
    curl -fsS -LO https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    curl -fsS -LO https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/heads/master.zip && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz && \
    unzip master.zip && \
    rm master.zip &&\
    cd nginx-1.22.1 && \
    patch -p1 < /tmp/ngx_http_proxy_connect_module-master/patch/proxy_connect_rewrite_102101.patch &&\
     cd /tmp/nginx-1.22.1 && \
    ./configure --add-module=/tmp/ngx_http_proxy_connect_module-master && \
    make && make install

# 清理临时文件
RUN rm -rf /tmp/*

# 设置 nginx 二进制文件的 PATH
ENV PATH="/usr/local/nginx/sbin:$PATH"

# 暴露 nginx 默认端口
EXPOSE 80


# 运行 nginx
CMD ["nginx", "-g", "daemon off;"]
