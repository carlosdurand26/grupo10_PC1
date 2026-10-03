FROM nginx:alpine
RUN apk add --no-cache iproute2 iputils
COPY docker/web/index.html /usr/share/nginx/html/index.html
COPY docker/web/default.conf /etc/nginx/conf.d/default.conf
