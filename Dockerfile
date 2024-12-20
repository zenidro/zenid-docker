FROM ubuntu:24.04 AS base
WORKDIR /server

RUN dpkg --add-architecture i386 && apt-get clean && apt-get update && \
    apt-get install -y \
    curl \
    jq \
    unzip \
    libssl-dev \
    sudo \
    ca-certificates \
    libc6:amd64 \
    libc6:i386 \
    libnode-dev:amd64 \
    libstdc++6:amd64 libstdc++6:i386 \
    libgcc-s1:amd64 libgcc-s1:i386 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base AS download_capi
WORKDIR /server
RUN curl -L -o CAPI.so "https://raw.githubusercontent.com/zenidro/omp-node-linux/main/CAPI.so"

FROM base AS download_config
WORKDIR /server
ENV CONFIG=config.json
RUN curl -L -o $CONFIG "https://raw.githubusercontent.com/zenidro/omp-node-linux/main/${CONFIG}"

FROM base AS download_openmp
WORKDIR /server
ENV OPENMP_FILE_NAME=omp-linux.zip
ENV OPENMP_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/${OPENMP_FILE_NAME}"
RUN curl -L -o $OPENMP_FILE_NAME $OPENMP_ARTIFACT_URL \
    && unzip -o $OPENMP_FILE_NAME \
    && rm $OPENMP_FILE_NAME

FROM base AS download_omp_node
WORKDIR /server
ENV OMP_NODE_FILE_NAME=node-linux.zip
ENV OMP_NODE_ARTIFACT_URL="https://raw.githubusercontent.com/zenidro/omp-node-linux/main/${OMP_NODE_FILE_NAME}"
RUN curl -L -o $OMP_NODE_FILE_NAME $OMP_NODE_ARTIFACT_URL \
    && unzip -o $OMP_NODE_FILE_NAME \
    && rm $OMP_NODE_FILE_NAME

FROM base AS final
WORKDIR /server
COPY --from=download_capi /server/CAPI.so /components/CAPI.so
COPY --from=download_config /server/config.json .
COPY --from=download_openmp /server/ .
COPY --from=download_omp_node /server/ .
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /server/omp-server && chmod +x /entrypoint.sh

#
EXPOSE 7777/udp
ENTRYPOINT ["/entrypoint.sh"]
