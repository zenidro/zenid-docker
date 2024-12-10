#!/bin/bash
cd /server

# Initialize an empty array to store the environment variables
OMP_CLI_ARGS=()

# Get all environment variables starting with OMP_
ENV_OPENMP_VARS=$(env | grep '^OMP_')

# Loop through each environment variable
while IFS= read -r ENV_VAR; do
    # Temporarily change Internal Field Separator to '=' to split the variable into name and value
    IFS='=' read -r VAR_NAME VAR_VALUE <<< "$ENV_VAR"

    # Remove the OMP_ prefix, convert double _ to . and convert the rest to lowercase
    VAR_NAME=$(echo "$VAR_NAME" | sed 's/^OMP_//g' | sed 's/__/\./g' | tr '[:upper:]' '[:lower:]')

    # Add VAR_NAME=VAR_VALUE to the array
    OMP_CLI_ARGS+=("$VAR_NAME=$VAR_VALUE")

done <<< "$ENV_OPENMP_VARS"

#######
#   RUN THE SERVER
#######

# Either run the Dockerfile CMD or the open.mp server
if [ $# -gt 0 ]; then
    echo -e "\nAlternative launching method: $@"
    sh -c "$@"
else
    ./omp-server -c "${OMP_CLI_ARGS[@]}"
fi

# Save the exit code of whatever we ran
EXIT_CODE=$?

exit $EXIT_CODE