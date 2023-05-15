#$/usr/bin/sh
apt install -y --no-install-recommends libtool unzip automake build-essential zlib1g zlib1g-dev libgd-dev

mkdir /www/app/nginx/ -p
mkdir /www/logs/nginx/ -p


# nginx模块
# https://tengine.taobao.org/download.html
tar xvf tengine-modules.tar.gz
# https://github.com/vozlt/nginx-module-vts
tar xvf nginx-module-vts-0.2.1.tar.gz -C modules/
# https://github.com/yaoweibin/ngx_http_substitutions_filter_module
tar xvf ngx_http_substitutions_filter_module_v0.6.4.tar.gz -C modules/
# https://github.com/yaoweibin/nginx_upstream_check_module
tar xvf nginx_upstream_check_module-0.4.0.tar.gz -C modules/
# https://github.com/FRiCKLE/ngx_cache_purge
# 并非官方包，二次开发了
tar xvf ngx_cache_purge-2.3.tar.gz -C modules/

# 第三方库
# https://www.pcre.org/
tar xvf pcre-8.45.tar.bz2
# https://www.openssl.org/source/
tar xvf openssl-3.1.0.tar.gz

#

# https://openresty.org/en/download.html
tar xvf openresty-1.21.4.2rc1.tar.gz

cd openresty-1.21.4.2rc1/bundle/nginx-1.21.4
patch -p1 < ../../../modules/nginx_upstream_check_module-0.4.0/check_1.20.1+.patch

cd ../../

./configure -j$(nproc) --prefix=/www/app \
--group=root --user=root \
--with-pcre=../pcre-8.45/ \
--with-pcre-jit \
--with-openssl=../openssl-3.1.0/ \
--with-threads \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-debug \
--with-file-aio \
--with-http_stub_status_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_ssl_module \
--with-http_image_filter_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_degradation_module \
--with-http_auth_request_module \
--with-http_slice_module \
--with-cc-opt='-O2 -I/usr/include' \
--with-ld-opt='-Wl,-E,-rpath,/usr/lib' \
--add-module=../modules/nginx-module-vts-0.2.1/ \
--add-module=../modules/ngx_http_substitutions_filter_module-0.6.4/ \
--add-module=../modules/ngx_cache_purge-2.3/ \
--add-module=../modules/ngx_backtrace_module \
--add-module=../modules/ngx_http_concat_module \
--add-module=../modules/ngx_slab_stat \
--add-module=../modules/nginx_upstream_check_module-0.4.0

make -j$(nproc)
make install

mkdir -p /www/app/nginx/conf/vhosts
mkdir -p /www/certs
