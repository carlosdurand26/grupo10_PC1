# Requiere la imagen FRRouting del proyecto ya cargada localmente.
# Solo modifica la imagen usada por los dos CPE.
FROM frr:10.7.1-ssh
RUN apt-get update \
    && apt-get install -y --no-install-recommends nftables \
    && rm -rf /var/lib/apt/lists/*
