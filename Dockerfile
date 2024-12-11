FROM ubuntu:20.04 AS base

RUN mkdir -p /components

WORKDIR /server

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CAPI=capi.so

RUN echo "Download CAPI component..." && curl -L -o /components/$CAPI "https://raw.githubusercontent.com/zenidro/omp-node-linux/main/%24CAPI.so"

ENV CONFIG=config.json

RUN echo "Download CONFIG component..." && curl -L -o /$CONFIG "https://raw.githubusercontent.com/zenidro/omp-node-linux/main/config.json"

ENV OPENMP_FILE_NAME=omp-linux.zip
ENV OPENMP_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/node-linux.zip"

RUN echo "Descarc OpenMP Artifact..." && \
    curl -L -o $OPENMP_FILE_NAME -H $OPENMP_ARTIFACT_URL && \
    unzip $OPENMP_FILE_NAME && \
    rm $OPENMP_FILE_NAME && \
    mv Server/* . && rmdir Server

ENV OMP_NODE_FILE_NAME=node-linux.zip
ENV OMP_NODE_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/node-linux.zip"

RUN echo "Descarc OMP Node Artifact..." && \
    curl -L -o $OMP_NODE_FILE_NAME -H $OMP_NODE_ARTIFACT_URL && \
    unzip $OMP_NODE_FILE_NAME && \
    rm $OMP_NODE_FILE_NAME

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x omp-server

EXPOSE 7777/udp

RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
