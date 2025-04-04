#!/usr/bin/env sh

set -eu

: "${STORAGE_DIRECTORY:=etc/axoflow-otel-collector/storage}"

detect_provider() {
    local provider=""
    local count=0

    env | grep -q "^AZURE_" && provider="$provider azure" && count=$((count + 1))
    env | grep -q "^AWS_" && provider="$provider aws" && count=$((count + 1))
    # env | grep -q "^GCP_" && provider="$provider gcp" && count=$((count + 1))

    if [ "$count" -gt 1 ]; then
        echo "Multiple cloud providers detected:${provider}"
        echo "   Only one provider per collector is allowed."
        exit 1
    fi

    echo "$provider" | xargs
}

if PROVIDER=$(detect_provider); then
    echo "Detected ${PROVIDER} configuration"
    exec ./axoflow-otel-collector --config "/etc/axoflow-otel-collector/connectors/common-config.yaml" --config "/etc/axoflow-otel-collector/connectors/${PROVIDER}/config.yaml"
fi

echo "No cloud provider configuration detected. Please set environment variables for one of:"
echo "   - Azure (AZURE_*)"
echo "   - AWS (AWS_*)"
# echo "   - GCP (GCP_*)"
exit 1
