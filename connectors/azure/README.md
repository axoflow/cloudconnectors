# Azure Event Hubs Connector

This directory contains the Axoflow Azure Event Hubs connector which helps collecting logs from Azure Event Hubs.

## Quickstart

Make sure the required environment variables are set before running the connector.

```bash
docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e AZURE_EVENT_HUBS_CONNECTION_STRING="${AZURE_EVENT_HUBS_CONNECTION_STRING}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
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
kubectl create secret generic azure-event-hubs \
  --from-literal=connection-string="<YOUR-AZURE-EVENT-HUBS-CONNECTION-STRING>" \
  --namespace cloudconnectors \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install --wait --namespace cloudconnectors cloudconnectors ./charts/cloudconnectors \
  --set image.repository="axocloudconnectors" \
  --set image.tag="dev" \
  --set 'env[0].name=AXOROUTER_ENDPOINT' \
  --set 'env[0].value=axorouter.axoflow-local.svc.cluster.local:4317' \
  --set 'env[1].name=AZURE_EVENT_HUBS_CONNECTION_STRING' \
  --set 'env[1].valueFrom.secretKeyRef.name=azure-event-hubs' \
  --set 'env[1].valueFrom.secretKeyRef.key=connection-string'
```
