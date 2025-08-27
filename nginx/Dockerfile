FROM openresty/openresty:alpine-fat

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-redis

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua /etc/nginx/lua
