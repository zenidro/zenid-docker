FROM debian:stable-slim AS base
WORKDIR /server
RUN dpkg --add-architecture i386 && apt-get clean && apt-get update && apt-get install -y libstdc++6:i386 curl jq wget unzip && apt-get upgrade -y

# Download OpenMP artifact
FROM base AS download_openmp
ARG WORKFLOW_OMP_ID=11808420148
ARG ARTIFACT_OMP_NAME=open.mp-linux-x86_64
RUN ARTIFACT_URL=$(curl -s "https://api.github.com/repos/openmultiplayer/open.mp/actions/runs/$WORKFLOW_OMP_ID/artifacts" | jq -r ".artifacts[] | select(.name | test(\"$ARTIFACT_OMP_NAME\")) | .archive_download_url") && \
    curl -L -o $ARTIFACT_OMP_NAME.zip $ARTIFACT_URL && unzip $ARTIFACT_OMP_NAME.zip && rm $ARTIFACT_OMP_NAME.zip && mv Server/* . && rmdir Server

# Download OMP Node artifact
FROM base AS download_ompnode
ARG WORKFLOW_NODE_ID=1234567890
ARG ARTIFACT_NODE_NAME=omp-node-linux
RUN ARTIFACT_URL=$(curl -s "https://api.github.com/repos/AmyrAhmady/omp-node/actions/runs/$WORKFLOW_NODE_ID/artifacts" | jq -r ".artifacts[] | select(.name | test(\"$ARTIFACT_NODE_NAME\")) | .archive_download_url") && \
    curl -L -o $ARTIFACT_NODE_NAME.zip $ARTIFACT_URL && unzip $ARTIFACT_NODE_NAME.zip && rm $ARTIFACT_NODE_NAME.zip && mv Server/* . && rmdir Server

# Download CAPI library
FROM base AS download_library
RUN curl -L -o /server/components/$CAPI.so "https://github.com/zenidro/capi-fixed/blob/main/%24CAPI.so"

# Final image to serve
FROM base AS final
WORKDIR /server

# Ensure the components directory exists in the final stage
RUN mkdir -p /server/components

# Copy the server directory from previous stages if necessary
COPY --from=download_openmp /server /server/
COPY --from=download_ompnode /server /server/
COPY --from=download_library /server/components /server/components/

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Set the correct permissions
RUN chmod +x omp-server /entrypoint.sh

EXPOSE 7777/udp
ENTRYPOINT [ "/entrypoint.sh" ]
