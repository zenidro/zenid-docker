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
    && rm -rf /var/lib/apt/lists/*

# Definirea variabilei pentru biblioteca CAPI
ENV CAPI=capi.so

# Descărcarea bibliotecii CAPI
RUN echo "Descărcăm biblioteca CAPI..." \
    && curl -L -o /components/$CAPI "https://raw.githubusercontent.com/zenidro/capi-fixed/main/%24CAPI.so" \
    && ls -l /components

# Setarea variabilelor pentru OpenMP Artifact
ENV OPENMP_FILE_NAME=open.mp-linux-x86_64-v1.3.1.2744-25-g4cb25eab.zip
ENV OPENMP_ARTIFACT_URL="https://api.github.com/repos/openmultiplayer/open.mp/actions/artifacts/2179619213/zip"

# Descărcarea OpenMP Artifact
RUN echo "Descarc OpenMP Artifact..." && \
    curl -L -o $OPENMP_FILE_NAME -H "Authorization: Bearer $GH_TOKEN" $OPENMP_ARTIFACT_URL && \
    ls -lh $OPENMP_FILE_NAME && \
    unzip $OPENMP_FILE_NAME && \
    rm $OPENMP_FILE_NAME && \
    mv Server/* . && rmdir Server

# Setarea variabilelor pentru OMP Node Artifact
ENV OMP_NODE_FILE_NAME=omp-node-linux.zip
ENV OMP_NODE_ARTIFACT_URL="https://api.github.com/repos/AmyrAhmady/omp-node/actions/artifacts/11895163134/zip"

# Descărcarea OMP Node Artifact
RUN echo "Descarc OMP Node Artifact..." && \
    curl -L -o $OMP_NODE_FILE_NAME -H "Authorization: Bearer $GH_TOKEN" $OMP_NODE_ARTIFACT_URL && \
    ls -lh $OMP_NODE_FILE_NAME && \
    unzip $OMP_NODE_FILE_NAME && \
    rm $OMP_NODE_FILE_NAME && \
    mv Server/* . && rmdir Server

# Copierea și setarea permisiunilor pentru entrypoint.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x omp-server

# Expunerea portului pentru server
EXPOSE 7777/udp

# Setarea permisiunilor pentru scriptul de entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
