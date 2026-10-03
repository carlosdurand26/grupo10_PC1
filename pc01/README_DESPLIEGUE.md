# PC1 - Despliegue del laboratorio

## Requisitos

- Ubuntu con Docker y Containerlab instalados.
- Conexión a Internet para descargar las imágenes base y paquetes.
- Recursos suficientes para ejecutar 27 contenedores.

## 1. Entrar al directorio del laboratorio

Desde la raíz del repositorio:

cd pc01

## 2. Construir FRRouting

sudo docker build \
  -t frr:10.7.1-ssh \
  docker/frr

## 3. Construir los CPE

sudo docker build \
  -t pc1-cpe-nat:10.7.1-ssh \
  -f docker/cpe/Dockerfile .

## 4. Construir el servidor web

sudo docker build \
  -t pc1-web:nginx-alpine \
  -f docker/web/Dockerfile .

## 5. Construir el cliente gráfico

sudo docker build \
  -t pc1-cliente-firefox:latest \
  -f docker/cliente/Dockerfile .

## 6. Desplegar la topología

sudo containerlab deploy --topo pc01.yml

## 7. Validar IPv4

sudo docker exec clab-pc01-cliente-empresa \
  curl -4 -I http://198.51.100.2/

## 8. Validar IPv6

sudo docker exec clab-pc01-cliente-empresa \
  curl -6 -g -I 'http://[2001:db8:100:50::2]/'

## 9. Verificar la redundancia

bash verificar_fase6c_monitor.sh

## 10. Acceder a Firefox

La interfaz gráfica del cliente se publica en el
puerto 5800 de localhost del equipo Ubuntu.

Si se utiliza VS Code mediante SSH, reenviar el
puerto 5800 y abrir:

http://localhost:5800/

Dentro de Firefox, visitar:

http://198.51.100.2/

## 11. Eliminar el laboratorio

sudo containerlab destroy --topo pc01.yml

## Observaciones

El acceso HTTP IPv4 e IPv6 fue validado en
condiciones normales.

Se validó la continuidad HTTP IPv4 ante la caída
de ISP-1 y la recuperación automática de ISP-1.

No se ha validado la continuidad HTTP IPv6
durante una caída de ISP-1.

El usuario SSH admin se crea sin contraseña fija.
Para utilizar autenticación SSH se debe configurar
una clave pública de forma segura.
