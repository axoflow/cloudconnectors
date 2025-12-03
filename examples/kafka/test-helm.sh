#!/bin/bash
set -e

KAFKA_BROKERS="${KAFKA_BROKERS:-kafka.kafka.svc.cluster.local:9092}"
KAFKA_LOGS_TOPIC="${KAFKA_LOGS_TOPIC:-otlp_logs}"

UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)
export AXOCLOUDCONNECTOR_DEVICE_ID

kubectl create secret generic kafka-credentials \
    --from-literal=brokers="${KAFKA_BROKERS}" \
    --from-literal=logs-topic="${KAFKA_LOGS_TOPIC}" \
    --namespace cloudconnectors \
    --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install --wait --namespace cloudconnectors cloudconnectors ../../charts/cloudconnectors \
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
    --set 'env[3].valueFrom.secretKeyRef.key=logs-topic' \
    --set 'env[4].name=AXOROUTER_TLS_INSECURE' \
    --set-string 'env[4].value=true' \
    --set 'env[5].name=KAFKA_TLS_INSECURE' \
    --set-string 'env[5].value=true'
