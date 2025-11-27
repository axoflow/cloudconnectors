# Axoflow cloudconnectors

This repository houses the cloudconnectors for Axoflow.

## Quickstart

You can find guides per connector:

- [Azure connector](./connectors/azure/README.md#quickstart)
- [AWS connector](./connectors/aws/README.md#quickstart)
- [Kafka connector](./connectors/kafka/README.md#quickstart)

## Environment Variables

### Common Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AXOROUTER_ENDPOINT` | Yes | - | Axorouter endpoint |
| `STORAGE_DIRECTORY` | No (Yes in case of Docker) | `/etc/axoflow-otel-collector/storage` | Directory used for persistence |
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

### Kafka Provider

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `KAFKA_BROKERS` | No | `localhost:9092` | Kafka broker addresses (e.g., `broker1:9092,broker2:9092`) |
| `KAFKA_PROTOCOL_VERSION` | No | `2.1.0` | Kafka protocol version |
| `KAFKA_RESOLVE_CANONICAL_BOOTSTRAP_SERVERS_ONLY` | No | `false` | Resolve then reverse-lookup broker IPs during startup |
| `KAFKA_LOGS_TOPIC` | No | `otlp_logs` | Topic for consuming logs |
| `KAFKA_LOGS_ENCODING` | No | `otlp_json` | Encoding for logs (otlp_proto, otlp_json, raw, text, json, azure_resource_logs) |
| `KAFKA_GROUP_ID` | No | `axocloudconnector` | Consumer group ID |
| `KAFKA_CLIENT_ID` | No | `axocloudconnector` | Kafka client ID |
| `KAFKA_INITIAL_OFFSET` | No | `latest` | Initial offset (`latest` or `earliest`) |
| `KAFKA_GROUP_INSTANCE_ID` | No | - | Unique identifier for static consumer group membership |
| `KAFKA_SESSION_TIMEOUT` | No | `10s` | Timeout for detecting client failures |
| `KAFKA_HEARTBEAT_INTERVAL` | No | `3s` | Expected time between heartbeats |
| `KAFKA_GROUP_REBALANCE_STRATEGY` | No | `range` | Partition assignment strategy (range, roundrobin, sticky) |
| `KAFKA_MIN_FETCH_SIZE` | No | `1` | Minimum message bytes to fetch |
| `KAFKA_DEFAULT_FETCH_SIZE` | No | `1048576` | Default message bytes to fetch (1MB) |
| `KAFKA_MAX_FETCH_SIZE` | No | `0` | Maximum message bytes to fetch (0 = unlimited) |
| `KAFKA_MAX_FETCH_WAIT` | No | `250ms` | Maximum wait time for min_fetch_size bytes |
| `KAFKA_TLS_INSECURE` | No | `false` | Use insecure connection |
| `KAFKA_TLS_CA_FILE` | No | - | Path to CA certificate file |
| `KAFKA_TLS_CERT_FILE` | No | - | Path to client certificate file |
| `KAFKA_TLS_KEY_FILE` | No | - | Path to client key file |
| `KAFKA_TLS_INSECURE_SKIP_VERIFY` | No | `false` | Skip TLS certificate verification |

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
