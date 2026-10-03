# Cliente grafico para la PC1: Firefox web/VNC de jlesage.
# La interfaz de gestion solo se publica en localhost de la VM por puerto 5800.
FROM jlesage/firefox:latest
RUN apk add --no-cache iproute2 iputils curl
ENV FF_OPEN_URL="http://198.51.100.2/"
