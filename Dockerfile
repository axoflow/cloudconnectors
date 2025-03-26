FROM ghcr.io/axoflow/axoflow-otel-collector/axoflow-otel-collector:0.120.0-axoflow.1 AS axo-otelcol

FROM alpine:3.21 AS base

WORKDIR /cloudconnectors
ENV HOME=/cloudconnectors

COPY --from=axo-otelcol /axoflow-otel-collector .
COPY --from=axo-otelcol /etc/axoflow-otel-collector/ /etc/axoflow-otel-collector/
COPY --from=axo-otelcol /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

RUN apk add --no-cache bash

# Set user
ARG USER_UID=10001
USER ${USER_UID}

# Copy application files
COPY entrypoint.sh ./
COPY connectors/ /etc/axoflow-otel-collector/connectors/

ENTRYPOINT ["./entrypoint.sh"]
