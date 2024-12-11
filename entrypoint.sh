#!/bin/bash
cd /server

OMP_CLI_ARGS=()

ENV_OPENMP_VARS=$(env | grep '^OMP_')

while IFS= read -r ENV_VAR; do
    IFS='=' read -r VAR_NAME VAR_VALUE <<< "$ENV_VAR"

    VAR_NAME=$(echo "$VAR_NAME" | sed 's/^OMP_//g' | sed 's/__/\./g' | tr '[:upper:]' '[:lower:]')

    OMP_CLI_ARGS+=("$VAR_NAME=$VAR_VALUE")

done <<< "$ENV_OPENMP_VARS"

if [ $# -gt 0 ]; then
    echo -e "\nAlternative launching method: $@"
    sh -c "$@"
else
    ./omp-server -c "${OMP_CLI_ARGS[@]}"
fi

EXIT_CODE=$?

exit $EXIT_CODE