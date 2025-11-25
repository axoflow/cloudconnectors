# Kafka Receiver Connector

This directory contains the Axoflow Kafka receiver connector which helps collecting logs from Kafka topics.

## Quickstart

Create a topic for your logs, e.g:

```sh
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: kafka-client
  namespace: kafka
spec:
  containers:
  - name: kafka-client
    image: docker.io/apache/kafka:4.1.1
    command: ["sleep", "infinity"]
EOF
kubectl wait --for=condition=ready pod/kafka-client -n kafka --timeout=60s

kubectl exec -n kafka kafka-client -- /opt/kafka/bin/kafka-topics.sh \
  --create \
  --topic otlp_logs \
  --partitions 3 \
  --replication-factor 1 \
  --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
  --if-not-exists
```

Make sure the required environment variables are set before running the connector.

### Using plaintext connection

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e KAFKA_BROKERS="${KAFKA_BROKERS}" \
        -e KAFKA_LOGS_TOPIC="${KAFKA_LOGS_TOPIC}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```

### Using TLS

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -v "${KAFKA_CERTS_PATH}:/certs:ro" \
        -e KAFKA_BROKERS="${KAFKA_BROKERS}" \
        -e KAFKA_LOGS_TOPIC="${KAFKA_LOGS_TOPIC}" \
        -e KAFKA_TLS_CA_FILE="/certs/ca.pem" \
        -e KAFKA_TLS_CERT_FILE="/certs/cert.pem" \
        -e KAFKA_TLS_KEY_FILE="/certs/key.pem" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```

## Deploy with Helm-chart

1. Set the required environment-variables.

### Example deploy with Axorouter in cluster

```bash
make minikube-cluster
make docker-build
make minikube-load-image

kubectl create namespace cloudconnectors
kubectl create secret generic kafka-credentials \
  --from-literal=brokers="<YOUR-KAFKA-BROKERS>" \
  --from-literal=logs-topic="<YOUR-KAFKA-LOGS-TOPIC>" \
  --namespace cloudconnectors \
  --dry-run=client -o yaml | kubectl apply -f -

UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

helm upgrade --install --wait --namespace cloudconnectors cloudconnectors ./charts/cloudconnectors \
  --set image.repository="axocloudconnectors" \
  --set image.tag="dev" \
  --set 'env[0].name=AXOROUTER_ENDPOINT' \
  --set 'env[0].value=axorouter.axoflow-local.svc.cluster.local:4317' \
  --set 'env[1].name=AXOCLOUDCONNECTOR_DEVICE_ID' \
  --set "env[1].value=${AXOCLOUDCONNECTOR_DEVICE_ID}" \
  --set 'env[2].name=KAFKA_BROKERS' \
  --set 'env[2].valueFrom.secretKeyRef.name=kafka-credentials' \
  --set 'env[2].valueFrom.secretKeyRef.key=brokers' \
  --set 'env[3].name=KAFKA_LOGS_TOPIC' \
  --set 'env[3].valueFrom.secretKeyRef.name=kafka-credentials' \
  --set 'env[3].valueFrom.secretKeyRef.key=logs-topic'
```
