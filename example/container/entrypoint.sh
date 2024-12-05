#!/bin/sh
set -euo pipefail

source_config=/opt/flexible-caching-proxy/nginx.conf.in
target_config=/etc/nginx/nginx.conf

rm -rf ${target_config}
cp ${source_config} ${target_config}

sed -i "s|\$MAX_SIZE|${MAX_SIZE:-10g}|" ${target_config}
sed -i "s|\$MAX_INACTIVE|${MAX_INACTIVE:-60m}|" ${target_config}
sed -i "s|\$UPSTREAM|${UPSTREAM}|" ${target_config}
sed -i "s|\$GZIP|${GZIP:-on}|" ${target_config}
sed -i "s|\$ALLOWED_ORIGIN|${ALLOWED_ORIGIN:-*}|" ${target_config}
sed -i "s|\$PROXY_READ_TIMEOUT|${PROXY_READ_TIMEOUT:-120s}|" ${target_config}

if [[ "${PROXY_CACHE_VALID+x}" ]]; then
  PROXY_CACHE_VALID="proxy_cache_valid ${PROXY_CACHE_VALID};"
fi
sed -i "s|\$PROXY_CACHE_VALID|${PROXY_CACHE_VALID-}|" ${target_config}

export NAMESERVER=`grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ' '`
sed -i "s|\$NAMESERVER|${NAMESERVER}|" ${target_config}

chown nginx /cache
exec "$@"
