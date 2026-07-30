FROM ghcr.io/axoflow/axoflow-otel-collector/axoflow-otel-collector:0.156.0-axoflow.3 AS axo-otelcol

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

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
