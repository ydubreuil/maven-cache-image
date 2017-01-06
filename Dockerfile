FROM nginx:mainline-alpine

ENV CACHE_SIZE_METADATA=10g
ENV CACHE_SIZE_ARTIFACT=30g
ENV CACHE_EXPIRE=30d

COPY nginx.conf /etc/nginx
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY entrypoint.sh /

RUN mkdir -p /cache/metadata /cache/default && \
  chown -R nginx /cache && \
  chmod 755 /entrypoint.sh

CMD ["/entrypoint.sh"]
