#!/bin/bash
set -e

kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: kafka
  namespace: kafka
  labels:
    app: kafka
spec:
  ports:
  - port: 9092
    name: plaintext
  clusterIP: None
  selector:
    app: kafka
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kafka
  namespace: kafka
spec:
  serviceName: kafka
  replicas: 1
  selector:
    matchLabels:
      app: kafka
  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
      - name: kafka
        image: docker.io/apache/kafka:4.1.1
        ports:
        - containerPort: 9092
          name: plaintext
        - containerPort: 9093
          name: controller
        env:
        - name: KAFKA_NODE_ID
          value: "1"
        - name: KAFKA_PROCESS_ROLES
          value: "broker,controller"
        - name: KAFKA_LISTENERS
          value: "PLAINTEXT://:9092,CONTROLLER://:9093"
        - name: KAFKA_ADVERTISED_LISTENERS
          value: "PLAINTEXT://kafka.kafka.svc.cluster.local:9092"
        - name: KAFKA_LISTENER_SECURITY_PROTOCOL_MAP
          value: "PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT"
        - name: KAFKA_CONTROLLER_LISTENER_NAMES
          value: "CONTROLLER"
        - name: KAFKA_CONTROLLER_QUORUM_VOTERS
          value: "1@kafka-0.kafka.kafka.svc.cluster.local:9093"
        - name: KAFKA_INTER_BROKER_LISTENER_NAME
          value: "PLAINTEXT"
        - name: KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR
          value: "1"
        - name: KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR
          value: "1"
        - name: KAFKA_TRANSACTION_STATE_LOG_MIN_ISR
          value: "1"
        - name: KAFKA_AUTO_CREATE_TOPICS_ENABLE
          value: "true"
        - name: CLUSTER_ID
          value: "5L6g3nShT-eMCtK--X86sw"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
EOF
kubectl wait --for=condition=ready pod -l app=kafka -n kafka --timeout=300s

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

echo -e "Listing topics..."
kubectl exec -n kafka kafka-client -- /opt/kafka/bin/kafka-topics.sh \
  --list \
  --bootstrap-server kafka.kafka.svc.cluster.local:9092
