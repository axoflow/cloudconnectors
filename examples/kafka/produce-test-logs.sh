#!/bin/bash
set -e

TOPIC="${KAFKA_LOGS_TOPIC:-otlp_logs}"
BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-kafka.kafka.svc.cluster.local:9092}"
INTERVAL="${LOG_INTERVAL:-5}"
COUNT="${LOG_COUNT:-0}"

if [ "$COUNT" -eq 0 ]; then
    echo "Count: infinite"
else
    echo "Count: ${COUNT} messages"
fi
echo ""

counter=0
while true; do
    counter=$((counter + 1))
    TIMESTAMP=$(date +%s)000000000
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sending message #${counter}..."
    
    cat <<EOF | kubectl exec -i -n kafka kafka-client -- /opt/kafka/bin/kafka-console-producer.sh --topic ${TOPIC} --bootstrap-server ${BOOTSTRAP_SERVER}
{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"test-service"}},{"key":"service.version","value":{"stringValue":"1.0.0"}},{"key":"message.number","value":{"intValue":${counter}}}]},"scopeLogs":[{"scope":{"name":"test-scope","version":"1.0"},"logRecords":[{"timeUnixNano":"${TIMESTAMP}","severityNumber":9,"severityText":"INFO","body":{"stringValue":"Test log message #${counter} from Kafka at $(date '+%Y-%m-%d %H:%M:%S')"},"attributes":[{"key":"log.source","value":{"stringValue":"kafka-test"}},{"key":"environment","value":{"stringValue":"development"}},{"key":"iteration","value":{"intValue":${counter}}}]}]}]}]}
EOF
    
    if [ $? -eq 0 ]; then
        echo "✓ Message #${counter} sent successfully"
    else
        echo "✗ Failed to send message #${counter}"
    fi
    
    if [ "$COUNT" -ne 0 ] && [ "$counter" -ge "$COUNT" ]; then
        echo ""
        echo "Completed sending ${COUNT} messages"
        break
    fi

    sleep "${INTERVAL}"
done

echo "Done!"
