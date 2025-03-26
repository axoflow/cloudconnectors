{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudconnectors.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudconnectors.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the release.
*/}}
{{- define "cloudconnectors.releasename" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Provides the namespace the chart will be installed in using the builtin .Release.Namespace,
or, if provided, a manually overwritten namespace value.
*/}}
{{- define "cloudconnectors.namespace" -}}
{{- if .Values.namespaceOverride -}}
{{ .Values.namespaceOverride -}}
{{- else -}}
{{ .Release.Namespace }}
{{- end -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudconnectors.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cloudconnectors.labels" -}}
app.kubernetes.io/name: {{ include "cloudconnectors.name" . }}
helm.sh/chart: {{ include "cloudconnectors.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "cloudconnectors.serviceAccountName" -}}
{{- if .Values.rbac.serviceAccount.create }}
{{- default (include "cloudconnectors.fullname" .) .Values.rbac.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rbac.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Storage path helper
*/}}
{{- define "cloudconnectors.storagePath" -}}
{{- default "/etc/axoflow-otel-collector/storage" .Values.storage.path -}}
{{- end -}}
