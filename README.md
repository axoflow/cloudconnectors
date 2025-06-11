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
| `AXOROUTER_TLS_INSECURE` | No | `false` | Whether to disable TLS security |
| `AXOROUTER_TLS_CA_FILE` | No | - | Path to the CA certificate file |
| `AXOROUTER_TLS_CA_PEM` | No | - | PEM-encoded CA certificate |
| `AXOROUTER_TLS_CERT_FILE` | No | - | Path to the client certificate file |
| `AXOROUTER_TLS_CERT_PEM` | No | - | PEM-encoded client certificate |
| `AXOROUTER_TLS_KEY_FILE` | No | - | Path to the client private key file |
| `AXOROUTER_TLS_KEY_PEM` | No | - | PEM-encoded client private key |
| `AXOROUTER_TLS_MIN_VERSION` | No | `1.2` | Minimum TLS version to use |
| `AXOROUTER_TLS_MAX_VERSION` | No | - | Maximum TLS version to use |
| `AXOROUTER_TLS_INCLUDE_SYSTEM_CA_CERTS_POOL` | No | `false` | Whether to include system CA certificates |
| `AXOROUTER_TLS_INSECURE_SKIP_VERIFY` | No | `false` | Whether to skip TLS certificate verification |
| `AXOCLOUDCONNECTOR_DEVICE_ID` | Yes | - | A service id that will be used to identify the cloud connector in Axoflow |

### Azure Provider

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AZURE_EVENT_HUBS_CONNECTION_STRING` | Yes | - | Azure Event Hubs connection string |

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

## License

The project is licensed under the [Apache 2.0 License](LICENSE).
