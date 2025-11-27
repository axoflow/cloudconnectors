
# CrowdStrike Falcon Receiver

This directory contains the Axoflow CrowdStrike Falcon receiver which helps collecting alerts from the CrowdStrike Falcon platform.

## Quickstart

### Authentication with ClientID / ClientSecret

Make sure the required environment variables are set before running the receiver.

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e CROWDSTRIKE_CLIENT_ID="${CROWDSTRIKE_CLIENT_ID}" \
        -e CROWDSTRIKE_CLIENT_SECRET="${CROWDSTRIKE_CLIENT_SECRET}" \
        -e CROWDSTRIKE_CLOUD="${CROWDSTRIKE_CLOUD}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```

### Authentication with Access Token

Make sure the required environment variables are set before running the receiver.

```bash
UUID_FULL=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
AXOCLOUDCONNECTOR_DEVICE_ID=$(echo "$UUID_FULL" | cut -d'-' -f1)

docker run \
        --rm \
        -v "${STORAGE_DIRECTORY}":"${STORAGE_DIRECTORY}" \
        -e CROWDSTRIKE_ACCESS_TOKEN="${CROWDSTRIKE_ACCESS_TOKEN}" \
        -e CROWDSTRIKE_CLOUD="${CROWDSTRIKE_CLOUD}" \
        -e AXOROUTER_ENDPOINT="${AXOROUTER_ENDPOINT}" \
        -e STORAGE_DIRECTORY="${STORAGE_DIRECTORY}" \
        -e AXOCLOUDCONNECTOR_DEVICE_ID="${AXOCLOUDCONNECTOR_DEVICE_ID}" \
        ghcr.io/axoflow/axocloudconnectors:latest
```


## Deploy with Helm-chart (ClientID / ClientSecret)

```bash
make minikube-cluster
make docker-build
make minikube-load-image

kubectl create namespace cloudconnectors
kubectl create secret generic crowdstrike-falcon \
  --from-literal=client-id="<YOUR-CROWDSTRIKE-CLIENT-ID>" \
  --from-literal=client-secret="<YOUR-CROWDSTRIKE-CLIENT-SECRET>" \
  --from-literal=cloud="<YOUR-CROWDSTRIKE-CLOUD>" \
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
  --set 'env[2].name=CROWDSTRIKE_CLIENT_ID' \
  --set 'env[2].valueFrom.secretKeyRef.name=crowdstrike-falcon' \
  --set 'env[2].valueFrom.secretKeyRef.key=client-id' \
  --set 'env[3].name=CROWDSTRIKE_CLIENT_SECRET' \
  --set 'env[3].valueFrom.secretKeyRef.name=crowdstrike-falcon' \
  --set 'env[3].valueFrom.secretKeyRef.key=client-secret' \
  --set 'env[4].name=CROWDSTRIKE_CLOUD' \
  --set 'env[4].valueFrom.secretKeyRef.name=crowdstrike-falcon' \
  --set 'env[4].valueFrom.secretKeyRef.key=cloud'
```

## Deploy with Helm-chart (Access Token)

```bash
kubectl create secret generic crowdstrike-falcon \
  --from-literal=access-token="<YOUR-CROWDSTRIKE-ACCESS-TOKEN>" \
  --from-literal=cloud="<YOUR-CROWDSTRIKE-CLOUD>" \
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
  --set 'env[2].name=CROWDSTRIKE_ACCESS_TOKEN' \
  --set 'env[2].valueFrom.secretKeyRef.name=crowdstrike-falcon' \
  --set 'env[2].valueFrom.secretKeyRef.key=access-token' \
  --set 'env[3].name=CROWDSTRIKE_CLOUD' \
  --set 'env[3].valueFrom.secretKeyRef.name=crowdstrike-falcon' \
  --set 'env[3].valueFrom.secretKeyRef.key=cloud'
```

