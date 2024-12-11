FROM ubuntu:20.04 AS base

# Crearea directorului de componente
RUN mkdir -p /components

WORKDIR /server

# Instalarea pachetelor necesare
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    file \
    && rm -rf /var/lib/apt/lists/*

# Definirea argumentului GH_TOKEN
ARG GH_TOKEN
ENV GH_TOKEN=${GH_TOKEN}

# Descarcă biblioteca CAPI
RUN echo "Descărcăm biblioteca CAPI..." && \
    curl -L -o /components/capi.so "https://raw.githubusercontent.com/zenidro/capi-fixed/main/%24CAPI.so" && \
    ls -l /components

# Descarcă OpenMP Artifact
RUN echo "Descarc OpenMP Artifact..." && \
    curl -L -o open.mp-linux-x86_64-v1.3.1.2744-25-g4cb25eab.tar.gz -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/openmultiplayer/open.mp/actions/artifacts/2179619213/zip && \
    file open.mp-linux-x86_64-v1.3.1.2744-25-g4cb25eab.tar.gz

# Descarcă OMP Node Artifact
RUN echo "Descarc OMP Node Artifact..." && \
    curl -L -o omp-node-linux.tar.gz -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/AmyrAhmady/omp-node/actions/artifacts/11895163134/zip && \
    file omp-node-linux.tar.gz

# Copiază entrypoint.sh în container
COPY entrypoint.sh /entrypoint.sh

# Schimbă permisiunile pentru fișierul omp-server
RUN chmod +x omp-server

# Expunerea portului pentru server
EXPOSE 7777

# Setează entrypoint-ul
ENTRYPOINT ["/entrypoint.sh"]

