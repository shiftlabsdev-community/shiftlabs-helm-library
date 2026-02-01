{{/*
ServiceMonitor resource
*/}}
{{- define "common.servicemonitor" -}}
{{- if .Values.metrics.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.metrics.serviceMonitor.additionalLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.metrics.serviceMonitor.namespace }}
  namespace: {{ . }}
  {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  endpoints:
    {{- range .Values.metrics.serviceMonitor.endpoints }}
    - port: {{ .port }}
      path: {{ .path | default "/metrics" }}
      interval: {{ .interval | default "30s" }}
      scrapeTimeout: {{ .scrapeTimeout | default "10s" }}
      {{- with .honorLabels }}
      honorLabels: {{ . }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end }}
