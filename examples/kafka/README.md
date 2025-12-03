# Kafka Connector Examples

## Prerequisites

It is assumed that you have Axoflow deployed locally.

## Quick Start

### 1. Deploy Kafka to Kubernetes

```bash
./deploy-kafka.sh
```

This script:

- Creates a `kafka` namespace
- Deploys Apache Kafka 4.1.1 in KRaft mode
- Creates a `kafka-client` pod for testing
- Creates the `otlp_logs` topic with 3 partitions

### 2. Test the Connector

#### Option A: Run in Kubernetes (Recommended)

```bash
# Build the connector image
cd ../../ && make docker-build && cd -

# Load the cloudconnector image to the cluster
minikube image load axocloudconnectors:dev

# Deploy via Helm
./test-helm.sh
```

This deploys the connector as a StatefulSet in the `cloudconnectors` namespace.

#### Option B: Run Locally with Docker

**Requirements:**

- Port-forward Kafka: `kubectl port-forward -n kafka pods/kafka-0 9092:9092`
- Port-forward AxoRouter: `kubectl port-forward -n axoflow-local pods/axorouter-0 4317:4317`

```bash
# Build the connector image
cd ../../ && make docker-build && cd -

# Run locally
./test-plaintext.sh
```

**Note:** On macOS, the script uses `host.docker.internal` to access port-forwarded services. It also maps Kafka's cluster DNS names using `--add-host` to work around Docker networking limitations.

### 3. Produce Test Logs

Send test OTLP log messages to Kafka:

```bash
./produce-test-logs.sh
```

This sends a sample OTLP JSON log message to the `otlp_logs` topic. The connector will consume it and forward it to Axorouter.

## Clean Up

```bash
# Remove Helm deployment
helm uninstall cloudconnectors -n cloudconnectors

# Remove Kafka
kubectl delete namespace kafka

# Remove local storage
rm -rf /tmp/kafka-connector-storage
```
