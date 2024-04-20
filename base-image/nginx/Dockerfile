ARG VERSION

FROM alpine:3 as build

ARG VERSION

RUN apk --update --no-cache add \
    gcc make g++ git wget linux-headers \
    pcre-dev openssl-dev zlib-dev \
    libmaxminddb libmaxminddb-dev libmaxminddb-doc
RUN wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz && \
    tar -xvzf nginx-${VERSION}.tar.gz

WORKDIR /nginx-${VERSION}

RUN git clone https://github.com/vozlt/nginx-module-vts.git ./nginx-module-vts && \
    git clone https://github.com/leev/ngx_http_geoip2_module.git ./geoip && \
    git clone https://github.com/AirisX/nginx_cookie_flag_module.git ./nginx_cookie_flag_module

RUN ./configure \
        --add-dynamic-module=./nginx-module-vts \
        --add-dynamic-module=./geoip \
        --add-dynamic-module=./nginx_cookie_flag_module \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-cc-opt='-Os -fomit-frame-pointer -g' \
        --with-ld-opt=-Wl,--as-needed,-O1,--sort-common
RUN make && \
    make install

FROM nginx:${VERSION}-alpine

COPY --from=build /usr/lib/nginx/modules/ /etc/nginx/modules/