# Tenable Audit Log Receiver

This directory contains the Axoflow Tenable connector, which collects audit events from the Tenable
Vulnerability Management audit log API (`/audit-log/v1/events`) and forwards them to Axorouter.

Each audit event becomes one log record whose body is the raw event and whose timestamp comes from the
event's `received` field. The connector follows pagination until the API stops returning a `next`
token and persists its position to disk, so it resumes where it left off across restarts.

## Quickstart

Make sure the required environment variables are set before running the connector.

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e TENABLE_ACCESS_KEY="${TENABLE_ACCESS_KEY}" \
        -e TENABLE_SECRET_KEY="${TENABLE_SECRET_KEY}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```

The API keys are generated in the Tenable UI under *My Account → API Keys*; the user needs permission
to read the audit log.

## Deploy with Helm-chart

```bash
make minikube-cluster
make docker-build
make minikube-load-image

kubectl create namespace cloudconnectors
kubectl create secret generic tenable \
  --from-literal=access-key="<YOUR-TENABLE-ACCESS-KEY>" \
  --from-literal=secret-key="<YOUR-TENABLE-SECRET-KEY>" \
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
  --set 'env[2].name=TENABLE_ACCESS_KEY' \
  --set 'env[2].valueFrom.secretKeyRef.name=tenable' \
  --set 'env[2].valueFrom.secretKeyRef.key=access-key' \
  --set 'env[3].name=TENABLE_SECRET_KEY' \
  --set 'env[3].valueFrom.secretKeyRef.name=tenable' \
  --set 'env[3].valueFrom.secretKeyRef.key=secret-key'
```

## Notes

- A failed poll leaves the checkpoint untouched, so the next poll retries the same window rather than
  skipping events. If the failure happens after part of a batch was already accepted, those events are
  re-sent.
- A `429 Too Many Requests` response suspends polling until the `Retry-After` deadline passes, falling
  back to `TENABLE_POLL_INTERVAL` when the header is missing.
- Tenable retains 30 days of audit events, so a `TENABLE_INITIAL_LOOKBACK` above `720h` gains nothing.
- Events without a parseable `received` field are still forwarded, but cannot advance the checkpoint
  and may be re-emitted while they remain inside the query window.
