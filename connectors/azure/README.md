# Azure Event Hubs Connector

This directory contains the Axoflow Azure Event Hubs Connector which helps collecting logs from Azure Event Hubs.

## Quickstart

Make sure the required environment variables are set before running the connector.

```bash
docker run \
        --rm \
        -v $(pwd)/config.yaml:/etc/axoflow-otel-collector/config.yaml \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e AZURE_EVENTHUB_CONNECTION_STRING="${AZURE_EVENTHUB_CONNECTION_STRING}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        ghcr.io/axoflow/cloudconnectors:latest
```

## Deploy with Helm-chart

1. Set the required environment-variables.
