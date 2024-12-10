FROM ubuntu:20.04 AS base

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CAPI=capi.so
ARG GH_TOKEN

RUN mkdir -p /server/components

RUN echo "Descărcăm biblioteca CAPI..." \
    && curl -L -o /server/components/$CAPI "https://raw.githubusercontent.com/zenidro/capi-fixed/main/%24CAPI.so" \
    && ls -l /server/components

RUN ARTIFACT_URL=$(curl -s -H "Authorization: Bearer $GH_TOKEN" "https://api.github.com/repos/openmultiplayer/open.mp/actions/runs/11808420148/artifacts" | jq -r '.artifacts[]? | select(.name | test("open.mp-linux-x86_64")) | .archive_download_url' || echo "Artifact not found") && \
    echo "OpenMP Artifact URL: $ARTIFACT_URL" && \
    if [ "$ARTIFACT_URL" == "Artifact not found" ]; then echo "Error: Artifact not found. Exiting."; exit 1; fi && \
    curl -L -o open.mp-linux-x86_64.zip $ARTIFACT_URL && \
    ls -lh open.mp-linux-x86_64.zip && \
    unzip open.mp-linux-x86_64.zip && \
    rm open.mp-linux-x86_64.zip && \
    mv Server/* . && rmdir Server

RUN ARTIFACT_URL=$(curl -s -H "Authorization: Bearer $GH_TOKEN" "https://api.github.com/repos/AmyrAhmady/omp-node/actions/runs/11895163134/artifacts" | jq -r '.artifacts[]? | select(.name | test("omp-node-linux")) | .archive_download_url' || echo "Artifact not found") && \
    echo "OMP Node Artifact URL: $ARTIFACT_URL" && \
    if [ "$ARTIFACT_URL" == "Artifact not found" ]; then echo "Error: Artifact not found. Exiting."; exit 1; fi && \
    curl -L -o omp-node-linux.zip $ARTIFACT_URL && \
    ls -lh omp-node-linux.zip && \
    unzip omp-node-linux.zip && \
    rm omp-node-linux.zip && \
    mv Server/* . && rmdir Server

WORKDIR /server
CMD ["./server_executable"]  # Înlocuiește cu numele executabilului serverului
