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
    curl -L -o $OPENMP_FILE_NAME $OPENMP_ARTIFACT_URL && \
    unzip -o $OPENMP_FILE_NAME && \
    ls -al / && \
    rm $OPENMP_FILE_NAME

ENV OMP_NODE_FILE_NAME=node-linux.zip
ENV OMP_NODE_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/node-linux.zip"

RUN echo "Descarc OMP Node Artifact..." && \
    curl -L -o $OMP_NODE_FILE_NAME $OMP_NODE_ARTIFACT_URL && \
    unzip -o $OMP_NODE_FILE_NAME && \
    ls -al / && \
    rm $OMP_NODE_FILE_NAME

COPY server .
COPY entrypoint.sh /entrypoint.sh

# Ensure the correct file path is used here
RUN chmod +x omp-server

EXPOSE 7777/udp

RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
