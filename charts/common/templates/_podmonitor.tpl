{{/*
PodMonitor resource
*/}}
{{- define "common.podmonitor" -}}
{{- if and .Values.metrics .Values.metrics.podMonitor .Values.metrics.podMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.metrics.podMonitor.additionalLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.metrics.podMonitor.namespace }}
  namespace: {{ . }}
  {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  podMetricsEndpoints:
    {{- range .Values.metrics.podMonitor.podMetricsEndpoints }}
    - port: {{ .port }}
      path: {{ .path | default "/metrics" }}
      interval: {{ .interval | default "30s" }}
      scrapeTimeout: {{ .scrapeTimeout | default "10s" }}
    {{- end }}
{{- end }}
{{- end }}
