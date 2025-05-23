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
  hostPath: "/root/.aws"
```

### Example deploy with Axorouter in cluster

```bash
make minikube-cluster
make docker-build
make minikube-load-image

kubectl create namespace cloudconnectors
kubectl create secret generic aws-credentials \
  --from-literal=access-key-id="<YOUR-AWS-ACCESS-KEY-ID>" \
  --from-literal=secret-access-key="<YOUR-AWS-SECRET-ACCESS-KEY>" \
  --namespace cloudconnectors \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install --wait --namespace cloudconnectors cloudconnectors ./charts/cloudconnectors \
  --set image.repository="axocloudconnectors" \
  --set image.tag="dev" \
  --set 'env[0].name=AXOROUTER_ENDPOINT' \
  --set 'env[0].value=axorouter.axoflow-local.svc.cluster.local:4317' \
  --set 'env[1].name=AWS_REGION' \
  --set 'env[1].value=<YOUR-AWS-REGION>' \
  --set 'env[2].name=AWS_ACCESS_KEY_ID' \
  --set 'env[2].valueFrom.secretKeyRef.name=aws-credentials' \
  --set 'env[2].valueFrom.secretKeyRef.key=access-key-id' \
  --set 'env[3].name=AWS_SECRET_ACCESS_KEY' \
  --set 'env[3].valueFrom.secretKeyRef.name=aws-credentials' \
  --set 'env[3].valueFrom.secretKeyRef.key=secret-access-key'
```
