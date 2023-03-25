FROM registry.access.redhat.com/ubi8/ubi-minimal

# 设置工作目录
WORKDIR /tmp

# 定义 Nginx 版本和 ngx_http_proxy_connect_module 版本
ARG NGINX_VERSION=1.22.1 

# 创建 /var/cache/yum 目录并设置权限
RUN mkdir -p /var/cache/yum && \
    chmod -R 777 /var/cache/yum

# 安装必要的软件包、下载 Nginx 和 ngx_http_proxy_connect_module 源码
USER 1001

RUN microdnf install -y gcc make unzip ca-certificates curl gnupg2 libpcre3-dev libssl-dev zlib1g-dev inetutils-ping telnet && \
    curl -fsS -LO https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    curl -fsS -LO https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/heads/master.zip && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz && \
    unzip master.zip && \
    rm master.zip && \
    cd nginx-${NGINX_VERSION} && \
    patch -p1 < /tmp/ngx_http_proxy_connect_module-master/patch/proxy_connect_rewrite_102101.patch && \
    cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure --add-module=/tmp/ngx_http_proxy_connect_module-master && \
    make && make install && \
    microdnf remove -y gcc make unzip ca-certificates curl gnupg2

# 清理临时文件
RUN rm -rf /tmp/*

# 设置 nginx 二进制文件的 PATH
ENV PATH="/usr/local/nginx/sbin:$PATH"

# 暴露 nginx 默认端口
LABEL io.k8s.description="Nginx Server" \
      io.k8s.display-name="nginx" \
      io.openshift.expose-services="80:http" \
      io.openshift.tags="nginx"

# 运行 nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]