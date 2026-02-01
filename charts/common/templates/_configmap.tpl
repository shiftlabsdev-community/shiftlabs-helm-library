{{/*
ConfigMap resource
*/}}
{{- define "common.configmap" -}}
{{- if .Values.configmap.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  {{- range .Values.configmap.fileData }}
  {{ .fileName }}: {{ .content | quote }}
  {{- end }}
  {{- range $key, $value := .Values.configmap.keyValues }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end }}
