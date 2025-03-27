# Axoflow cloudconnectors

This repository houses the cloudconnectors for Axoflow.

## Quickstart

You can find guides per connector:

- [Azure connector](./connectors/azure/README.md#quickstart)
- [AWS connector](./connectors/aws/README.md#quickstart)

## Environment Variables

### Common Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AXOROUTER_ENDPOINT` | Yes | - | Axorouter endpoint |
| `STORAGE_DIRECTORY` | No | `/etc/axoflow-otel-collector/storage` | Directory used for persistence |

### Azure Provider

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AZURE_EVENTHUB_CONNECTION_STRING` | Yes | - | Azure Event Hub connection string |

### AWS Provider

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AWS_REGION` | Yes | - | AWS region to connect to |
| `AWS_PROFILE` | No | - | AWS profile name to use from config |
| `AWS_SDK_LOAD_CONFIG` | No | - | Set to 1 to load AWS config |
| `AWS_ACCESS_KEY_ID` | No | - | AWS access key ID for direct authentication |
| `AWS_SECRET_ACCESS_KEY` | No | - | AWS secret access key for direct authentication |

## Usage

### Local Development with Docker

```bash
# Build the Docker image
make docker-build
```

### Kubernetes Deployment

For local Kubernetes deployment using MiniKube:

```bash
# Create a local Kubernetes cluster
make minikube-cluster

# Install the Helm chart
make install

# Uninstall the Helm chart
make uninstall
```
