#!/usr/bin/env sh

set -eu

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

is_prod_config_needed() {
    local config_type=""

    if [ -n "${AXOROUTER_CA_FILE:-}" ] || \
       [ -n "${AXOROUTER_CA_PEM:-}" ] || \
       [ -n "${AXOROUTER_CERT_FILE:-}" ] || \
       [ -n "${AXOROUTER_CERT_PEM:-}" ] || \
       [ -n "${AXOROUTER_KEY_FILE:-}" ] || \
       [ -n "${AXOROUTER_KEY_PEM:-}" ] || \
       [ -n "${AXOROUTER_TLS_MIN_VERSION:-}" ] || \
       [ -n "${AXOROUTER_TLS_MAX_VERSION:-}" ] || \
       [ -n "${AXOROUTER_INCLUDE_SYSTEM_CA_CERTS_POOL:-}" ] || \
       [ -n "${AXOROUTER_INSECURE_SKIP_VERIFY:-}" ]; then
       config_type="prod"
    else
        config_type="dev"
    fi

    echo "$config_type" | xargs
}

if PROVIDER=$(detect_provider) && CONFIG_TYPE=$(is_prod_config_needed); then
    echo "Detected ${PROVIDER} configuration with ${CONFIG_TYPE} settings."
    exec ./axoflow-otel-collector --config "/etc/axoflow-otel-collector/connectors/common-config-${CONFIG_TYPE}.yaml" --config "/etc/axoflow-otel-collector/connectors/${PROVIDER}/config.yaml"
fi

echo "No cloud provider configuration detected. Please set environment variables for one of:"
echo "   - Azure (AZURE_*)"
echo "   - AWS (AWS_*)"
# echo "   - GCP (GCP_*)"
exit 1
