# Idira Connector

This directory contains the Axoflow Idira connector, which collects audit events from the Idira SIEM
integration stream API and forwards them to Axorouter.

Each poll opens a date-filtered query (`createQuery`) and follows the returned cursor page by page
(`results`) until a page comes back empty. Every audit event becomes one log record. The end of each
poll window is checkpointed to disk, so it resumes where it left off across restarts.

Requests are authenticated with an OAuth 2 client credentials token from the Identity Administration
token endpoint plus the SIEM integration API key.

## Quickstart

Make sure the required environment variables are set before running the connector.

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e IDIRA_ENDPOINT="${IDIRA_ENDPOINT}" \
        -e IDIRA_API_KEY="${IDIRA_API_KEY}" \
        -e IDIRA_TOKEN_URL="${IDIRA_TOKEN_URL}" \
        -e IDIRA_CLIENT_ID="${IDIRA_CLIENT_ID}" \
        -e IDIRA_CLIENT_SECRET="${IDIRA_CLIENT_SECRET}" \
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
kubectl create secret generic idira \
  --from-literal=endpoint="<YOUR-IDIRA-AUDIT-ENDPOINT>" \
  --from-literal=api-key="<YOUR-IDIRA-API-KEY>" \
  --from-literal=token-url="<YOUR-IDIRA-TOKEN-URL>" \
  --from-literal=client-id="<YOUR-IDIRA-CLIENT-ID>" \
  --from-literal=client-secret="<YOUR-IDIRA-CLIENT-SECRET>" \
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
  --set 'env[2].name=IDIRA_ENDPOINT' \
  --set 'env[2].valueFrom.secretKeyRef.name=idira' \
  --set 'env[2].valueFrom.secretKeyRef.key=endpoint' \
  --set 'env[3].name=IDIRA_API_KEY' \
  --set 'env[3].valueFrom.secretKeyRef.name=idira' \
  --set 'env[3].valueFrom.secretKeyRef.key=api-key' \
  --set 'env[4].name=IDIRA_TOKEN_URL' \
  --set 'env[4].valueFrom.secretKeyRef.name=idira' \
  --set 'env[4].valueFrom.secretKeyRef.key=token-url' \
  --set 'env[5].name=IDIRA_CLIENT_ID' \
  --set 'env[5].valueFrom.secretKeyRef.name=idira' \
  --set 'env[5].valueFrom.secretKeyRef.key=client-id' \
  --set 'env[6].name=IDIRA_CLIENT_SECRET' \
  --set 'env[6].valueFrom.secretKeyRef.name=idira' \
  --set 'env[6].valueFrom.secretKeyRef.key=client-secret'
```

## Notes

- `IDIRA_TOKEN_URL` is the Identity Administration OAuth 2 token endpoint, in the form
  `https://<identity_fqdn>/OAuth2/Token/<web_app_id>`.
- The audit API accepts one query per minute, so `IDIRA_POLL_INTERVAL` below `1m` is rejected at
  startup.
- The date filter has one-second granularity and each poll starts where the previous one ended, so
  events on that boundary second can be delivered twice. Deduplicate on the event `uuid` downstream
  if that matters.
- `IDIRA_APPLICATION_CODES` is parsed as a YAML list: `'[DPA]'` for one code, `'[DPA,ISP]'` for
  several. Unset means no application filter.
- Requires the `idira` receiver to be present in the axoflow-otel-collector image.
