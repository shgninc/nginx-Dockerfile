FROM debian:bullseye-slim

LABEL maintainer "Seyed Sajjad Shahcheraghian <shgninc@gmail.com>"

ARG NGX_VERSION="1.22.0"
ARG OPENSSL_VERSION="1.1.1o"
ARG PCRE_VERSION="10.40"
ARG IP2L_VERSION="8.3.1-1"
ARG NGX_MOD_OPTIONS="--add-module=/tmp/nginx-module-vts-master --add-module=/tmp/headers-more-nginx-module-master --add-dynamic-module=/tmp/nginx-module-stream-sts-master --add-dynamic-module=/tmp/nginx-module-sts-master --add-dynamic-module=/tmp/ngx_devel_kit-master --add-dynamic-module=/tmp/set-misc-nginx-module-master --add-dynamic-module=/tmp/ngx_http_substitutions_filter_module-master"
ARG NGX_CONFIG_DEPS="--with-openssl=/tmp/openssl-${OPENSSL_VERSION} --with-pcre=/tmp/pcre2-${PCRE_VERSION}"

RUN set -x \
    && DEBIAN_FRONTEND=noninteractive apt update \
    && DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
	ca-certificates make gcc g++ pkg-config unzip libtool autoconf automake git vim curl iputils-ping apt-transport-https ca-certificates supervisor procps openssh-client\
	zlib1g-dev libxslt1-dev libgd-dev libgeoip-dev uuid-dev \
    && cd /tmp \
    ## Openssl
    && curl -fSL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -o openssl-${OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${OPENSSL_VERSION}.tar.gz \
    ## PCRE
    && curl -fSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VERSION}/pcre2-${PCRE_VERSION}.tar.gz -o pcre2-${PCRE_VERSION}.tar.gz \
    && tar xzf pcre2-${PCRE_VERSION}.tar.gz \
    ## Nginx
    && curl -fSL http://nginx.org/download/nginx-${NGX_VERSION}.tar.gz -o nginx-${NGX_VERSION}.tar.gz \
    && tar xzf nginx-${NGX_VERSION}.tar.gz \
    ## Nginx VTS
    && curl -fSL https://github.com/vozlt/nginx-module-vts/archive/master.zip -o nginx-module-vts.zip \
    && unzip nginx-module-vts.zip \
    ## Nginx more-headers
    && curl -fSL https://codeload.github.com/openresty/headers-more-nginx-module/zip/master -o headers-more-nginx-module.zip \
    && unzip headers-more-nginx-module.zip \
    ## Nginx STS
    && curl -fSL https://github.com/vozlt/nginx-module-sts/archive/master.zip -o nginx-module-sts.zip \
    && unzip nginx-module-sts.zip \
    ## Nginx Stream STS
    && curl -fSL https://github.com/vozlt/nginx-module-stream-sts/archive/master.zip -o nginx-module-stream-sts.zip \
    && unzip nginx-module-stream-sts.zip \
    ## Nginx Misc
    && curl -fSL https://github.com/openresty/set-misc-nginx-module/archive/master.zip -o set-misc-nginx-module-master.zip \
    && unzip set-misc-nginx-module-master.zip \
    ## Nginx Devel kit
    && curl -fSL https://github.com/vision5/ngx_devel_kit/archive/master.zip -o ngx_devel_kit-master.zip \
    && unzip ngx_devel_kit-master.zip \
    ## Nginx substitute
    && curl -fSL https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/master.zip -o ngx_http_substitutions_filter_module-master.zip \
    && unzip ngx_http_substitutions_filter_module-master.zip \
    && cd /tmp/nginx-${NGX_VERSION} \
    && sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c \
    && ./configure \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/logs/error.log \
        --http-log-path=/logs/access.log \
        --pid-path=/run/nginx.pid \
        --lock-path=/var/lock/nginx.lock \
        --user=www-data \
        --group=www-data \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_geoip_module=dynamic \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_image_filter_module=dynamic \
        #--with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_xslt_module=dynamic \
        --with-pcre-jit \
	--with-md5-asm \
        --with-stream=dynamic \
        --with-stream_ssl_module \
        --with-threads \
        --with-debug \
        --with-pcre=../pcre2-${PCRE_VERSION} \
	--without-http_uwsgi_module \
	--without-http_scgi_module \
	--without-mail_pop3_module \
	--without-mail_imap_module \
	--without-mail_smtp_module \
        --with-cc-opt='-O2 -fstack-protector-strong -Wformat -Werror=format-security -fPIC -D_FORTIFY_SOURCE=2' \
        --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' \
        ${NGX_CONFIG_DEPS} ${NGX_MOD_OPTIONS} \
    && make -j$(nproc) \
    && make -j$(nproc) install \
    && rm -rf /tmp/* \
        openssl-${OPENSSL_VERSION} \
        openssl-${OPENSSL_VERSION}.tar.gz \
        nginx-${NGX_VERSION}.tar.gz nginx-${NGX_VERSION} \
        pcre2-${PCRE_VERSION}.tar.gz pcre2-${PCRE_VERSION} \
	nginx-module-vts-master nginx-module-vts.zip \
	headers-more-nginx-module-master headers-more-nginx-module.zip \
	nginx-module-stream-sts-master nginx-module-stream-sts.zip \
	nginx-module-sts-master nginx-module-sts.zip \
	ngx_devel_kit-master ngx_devel_kit-master.zip \
	set-misc-nginx-module-master set-misc-nginx-module-master.zip \
	ngx_http_substitutions_filter_module-master ngx_http_substitutions_filter_module-master.zip \
	ip2location-nginx-master ip2location-nginx-master.zip \
	IP2Location-C-Library-${IP2L_VERSION}.zip IP2Location-C-Library-${IP2L_VERSION} \
    && DEBIAN_FRONTEND=noninteractive apt remove -y --purge make automake autoconf gcc g++ pkg-config \
    && DEBIAN_FRONTEND=noninteractive apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY ssl/ /etc/ssl/
COPY nginx.conf /etc/nginx/
COPY conf.d/ /conf.d/
COPY nginx.conf.d/ /etc/nginx/conf.d/
COPY error_pages/* /var/www/default/errors/

EXPOSE 80 443

CMD nginx
