FROM ubuntu:20.04 AS base
WORKDIR /server

RUN apt-get clean && apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    libssl-dev \
    libffi-dev \
    libnode-dev \
    libc6-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base AS download_capi
WORKDIR /server
RUN curl -L -o CAPI.so "https://raw.githubusercontent.com/zenidro/omp-node-linux/main/CAPI.so"

FROM base AS download_config
WORKDIR /server
ENV CONFIG=config.json
RUN curl -L -o $CONFIG "https://raw.githubusercontent.com/zenidro/omp-node-linux/main/config.json"

FROM base AS download_openmp
WORKDIR /server
ENV OPENMP_FILE_NAME=omp-linux.zip
ENV OPENMP_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/omp-linux.zip"
RUN curl -L -o $OPENMP_FILE_NAME $OPENMP_ARTIFACT_URL \
    && unzip -o $OPENMP_FILE_NAME \
    && rm $OPENMP_FILE_NAME

FROM base AS download_omp_node
WORKDIR /server
ENV OMP_NODE_FILE_NAME=node-linux.zip
ENV OMP_NODE_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/node-linux.zip"
RUN curl -L -o $OMP_NODE_FILE_NAME $OMP_NODE_ARTIFACT_URL \
    && unzip -o $OMP_NODE_FILE_NAME \
    && rm $OMP_NODE_FILE_NAME

FROM base AS final
WORKDIR /server
COPY --from=download_capi /server/CAPI.so /components/CAPI.so
COPY --from=download_config /server/config.json /config.json
COPY --from=download_openmp /server /server
COPY --from=download_omp_node /server /server
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /server/omp-server && chmod +x /entrypoint.sh

EXPOSE 7777/udp
ENTRYPOINT ["/entrypoint.sh"]
