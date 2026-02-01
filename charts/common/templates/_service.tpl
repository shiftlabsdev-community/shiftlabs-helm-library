{{/*
Service resource
Supports optional .Values.service.enabled guard (for CronJob charts where service is optional)
If .Values.service.enabled is not defined, service is always rendered (backward compat).
*/}}
{{- define "common.service" -}}
{{- $enabled := true -}}
{{- if hasKey .Values.service "enabled" -}}
{{- $enabled = .Values.service.enabled -}}
{{- end -}}
{{- if $enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  {{- if and (eq .Values.service.type "LoadBalancer") .Values.service.loadBalancerIP }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  {{- end }}
  ports:
    {{- range .Values.service.ports }}
    - port: {{ .port }}
      protocol: {{ .protocol }}
      targetPort: {{ .targetPort }}
      name: {{ .name }}
    {{- end }}
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end }}
