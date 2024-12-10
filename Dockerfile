# Step 1: Folosim o imagine de bază
FROM ubuntu:20.04 AS base

# Step 2: Instalăm dependențele necesare
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Step 3: Setăm variabilele de mediu (dacă sunt necesare)
ENV CAPI=capi.so

# Step 4: Asigurăm că directorul pentru componente există
RUN mkdir -p /server/components

# Step 5: Descărcăm biblioteca CAPI
RUN echo "Descărcăm biblioteca CAPI..." \
    && curl -L -o /server/components/$CAPI "https://raw.githubusercontent.com/zenidro/capi-fixed/main/%24CAPI.so" \
    && ls -l /server/components

# Step 6: Descărcăm artefactul OpenMP
RUN ARTIFACT_URL=$(curl -s "https://api.github.com/repos/openmultiplayer/open.mp/actions/runs/11808420148/artifacts" | jq -r '.artifacts[]? | select(.name | test("open.mp-linux-x86_64")) | .archive_download_url' || echo "Artifact not found") && \
    echo "OpenMP Artifact URL: $ARTIFACT_URL" && \
    if [ "$ARTIFACT_URL" == "Artifact not found" ]; then echo "Error: Artifact not found. Exiting."; exit 1; fi && \
    curl -L -o open.mp-linux-x86_64.zip $ARTIFACT_URL && \
    ls -lh open.mp-linux-x86_64.zip && \
    unzip open.mp-linux-x86_64.zip && \
    rm open.mp-linux-x86_64.zip && \
    mv Server/* . && rmdir Server

# Step 7: Descărcăm artefactul OMP Node
RUN ARTIFACT_URL=$(curl -s "https://api.github.com/repos/AmyrAhmady/omp-node/actions/runs/11895163134/artifacts" | jq -r '.artifacts[]? | select(.name | test("omp-node-linux")) | .archive_download_url' || echo "Artifact not found") && \
    echo "OMP Node Artifact URL: $ARTIFACT_URL" && \
    if [ "$ARTIFACT_URL" == "Artifact not found" ]; then echo "Error: Artifact not found. Exiting."; exit 1; fi && \
    curl -L -o omp-node-linux.zip $ARTIFACT_URL && \
    ls -lh omp-node-linux.zip && \
    unzip omp-node-linux.zip && \
    rm omp-node-linux.zip && \
    mv Server/* . && rmdir Server

# Step 8: Finalizare imagine pentru server
WORKDIR /server
CMD ["./server_executable"]  # Înlocuiește cu numele executabilului serverului
