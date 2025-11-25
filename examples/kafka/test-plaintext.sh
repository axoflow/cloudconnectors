#!/bin/bash
set -e

KAFKA_BROKERS="${KAFKA_BROKERS:-host.docker.internal:9092}"
KAFKA_LOGS_TOPIC="${KAFKA_LOGS_TOPIC:-otlp_logs}"
AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT:-http://host.docker.internal:4317}"
STORAGE_DIRECTORY="${STORAGE_DIRECTORY:-/tmp/kafka-connector-storage}"

UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)
export AXOCLOUDCONNECTOR_DEVICE_ID

mkdir -p "${STORAGE_DIRECTORY}"

docker run --rm \
  --add-host=kafka.kafka.svc.cluster.local:host-gateway \
  --add-host=kafka-0.kafka.kafka.svc.cluster.local:host-gateway \
  -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
  -e KAFKA_BROKERS="${KAFKA_BROKERS}" \
  -e KAFKA_LOGS_TOPIC="${KAFKA_LOGS_TOPIC}" \
  -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
  -e AXOROUTER_TLS_INSECURE="true" \
  -e KAFKA_TLS_INSECURE="true" \
  -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
  -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
  axocloudconnectors:dev
