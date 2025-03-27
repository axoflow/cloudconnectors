# AWS CloudWatch

This directory contains the Axoflow AWS CloudWatch connector which helps collecting logs from CloudWatch.

## Quickstart

Make sure the required environment variables are set before running the connector.

There are many ways you can authenticate and use the CloudWatch service:

### Using AWS Profile with a config file

```bash
docker run --rm \
  -e AWS_PROFILE="${AWS_PROFILE}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AWS_SDK_LOAD_CONFIG=1 \
  -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
  -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
  -v "${HOME}/.aws:/cloudconnectors/.aws:ro" \
  ghcr.io/axoflow/axocloudconnectors:latest
```

### Direct AWS credentials

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
  -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
  ghcr.io/axoflow/axocloudconnectors:latest
```

### Using EC2 instance profile

```bash
docker run --rm \
  -e AWS_REGION="${AWS_REGION}" \
  -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
  -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
  ghcr.io/axoflow/axocloudconnectors:latest
```

## Deploy with Helm-chart

1. Set the required environment-variables.
2. Based on your authentication method you might need to set the following values:

```yaml
# -- AWS configuration
awsConfig:
  # -- AWS credentials configuration
  enabled: true
  # -- Use secret for AWS credentials
  useSecret: false
  # -- Secret configuration (when useSecret: true)
  secretName: ""
  # -- Filesystem configuration (when useSecret: false)
  hostPath: "$(HOME)/.aws"
```
