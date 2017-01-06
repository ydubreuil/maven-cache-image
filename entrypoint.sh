#!/bin/sh

# generate NGinx configuration from template
envsubst '${CACHE_SIZE_METADATA},${CACHE_SIZE_ARTIFACT},${CACHE_EXPIRE}' \
 < /etc/nginx/conf.d/default.conf.template \
 > /etc/nginx/conf.d/default.conf

nginx -g 'daemon off;'
