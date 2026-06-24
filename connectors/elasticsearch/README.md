
# Elasticsearch Logs Receiver

This directory contains the Axoflow Elasticsearch connector, which collects logs from an
Elasticsearch cluster by polling the `_search` API and forwards them to Axorouter.

It paginates with `search_after` over a stable sort and persists a per-index cursor to disk, so it
resumes where it left off across restarts.

## Quickstart

Make sure the required environment variables are set before running the connector.

### Authentication with an API key

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e ELASTICSEARCH_ENDPOINT="${ELASTICSEARCH_ENDPOINT}" \
        -e ELASTICSEARCH_API_KEY="${ELASTICSEARCH_API_KEY}" \
        -e ELASTICSEARCH_INDEX="${ELASTICSEARCH_INDEX}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```

### Authentication with username / password

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e ELASTICSEARCH_ENDPOINT="${ELASTICSEARCH_ENDPOINT}" \
        -e ELASTICSEARCH_USERNAME="${ELASTICSEARCH_USERNAME}" \
        -e ELASTICSEARCH_PASSWORD="${ELASTICSEARCH_PASSWORD}" \
        -e ELASTICSEARCH_INDEX="${ELASTICSEARCH_INDEX}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```

## Deploy with Helm-chart

```bash
make minikube-cluster
make docker-build
make minikube-load-image

kubectl create namespace cloudconnectors
kubectl create secret generic elasticsearch \
  --from-literal=endpoint="<YOUR-ELASTICSEARCH-ENDPOINT>" \
  --from-literal=api-key="<YOUR-ELASTICSEARCH-API-KEY>" \
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
  --set 'env[2].name=ELASTICSEARCH_ENDPOINT' \
  --set 'env[2].valueFrom.secretKeyRef.name=elasticsearch' \
  --set 'env[2].valueFrom.secretKeyRef.key=endpoint' \
  --set 'env[3].name=ELASTICSEARCH_API_KEY' \
  --set 'env[3].valueFrom.secretKeyRef.name=elasticsearch' \
  --set 'env[3].valueFrom.secretKeyRef.key=api-key' \
  --set 'env[4].name=ELASTICSEARCH_INDEX' \
  --set 'env[4].value=logs-*'
```

## Notes

- `search_after` requires a stable, deterministic sort. The connector defaults to
  `[{"@timestamp": asc}, {"_seq_no": asc}]`; the last entry must be unique per document. If your
  documents use a different time field, set `ELASTICSEARCH_TIMESTAMP_FIELD` and adjust the `sort` in
  `config.yaml` accordingly.
- With `ELASTICSEARCH_START_AT=end` (the default) and `ELASTICSEARCH_INITIAL_LOOKBACK=0`, documents
  whose timestamp precedes startup but that are indexed afterwards (indexing lag or clock skew) can be
  missed. The default lookback of `1h` covers that window; increase it if needed, or use
  `ELASTICSEARCH_START_AT=beginning` to read all history.
