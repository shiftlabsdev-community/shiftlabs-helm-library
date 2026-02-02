{{/*
ExternalSecret resource
*/}}
{{- define "common.externalsecret" -}}
{{- if and .Values.ExternalSecret .Values.ExternalSecret.enabled -}}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: {{ .Values.ExternalSecret.name }}
    kind: SecretStore
  target:
    name: {{ include "common.fullname" . }}
    creationPolicy: Owner
    deletionPolicy: Retain
  {{- if eq .Values.ExternalSecret.type "hashicorp" }}
  dataFrom:
  {{- range .Values.ExternalSecret.kvPath }}
    - extract:
        key: {{ . }}
        metadataPolicy: None
        decodingStrategy: None
        conversionStrategy: Default
  {{- end }}
  {{- else if eq .Values.ExternalSecret.type "aws" }}
  dataFrom:
  {{- range .Values.ExternalSecret.kvPath }}
    - extract:
        key: {{ . }}
  {{- end }}
  {{- else if eq .Values.ExternalSecret.type "gcp" }}
  dataFrom:
  {{- range .Values.ExternalSecret.kvPath }}
    - extract:
        key: {{ . }}
  {{- end }}
  {{- else if eq .Values.ExternalSecret.type "azure" }}
  dataFrom:
  {{- range .Values.ExternalSecret.kvPath }}
    - extract:
        key: {{ . }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
