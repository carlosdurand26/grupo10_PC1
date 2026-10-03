FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    openssh-server \
    iproute2 \
    iputils-ping \
    procps && \
    rm -rf /var/lib/apt/lists/*

COPY frrouting.gpg /etc/apt/keyrings/frrouting.gpg
COPY frr.list /etc/apt/sources.list.d/frr.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    frr=10.7.1-0~deb13u1 \
    frr-pythontools=10.7.1-0~deb13u1 && \
    sed -i -E \
    's/^(zebra|bgpd|ospfd|ospf6d|isisd|ldpd|staticd|vrrpd)=no/\1=yes/' \
    /etc/frr/daemons && \
    mkdir -p /run/sshd /run/frr && \
    touch /etc/frr/frr.conf && \
    chown -R frr:frr /etc/frr /run/frr && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /usr/local/bin/start.sh

RUN chmod 755 /usr/local/bin/start.sh

RUN useradd -m -s /bin/bash admin \
    && usermod -aG frrvty admin

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/start.sh"]
