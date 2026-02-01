{{/*
VerticalPodAutoscaler resource
*/}}
{{- define "common.vpa" -}}
{{- if .Values.verticalPodAutoscaler.enabled }}
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: {{ .Values.verticalPodAutoscaler.targetKind | default "Deployment" }}
    name: {{ include "common.fullname" . }}
  updatePolicy:
    updateMode: {{ .Values.verticalPodAutoscaler.updatePolicy.updateMode | default "Auto" }}
  {{- with .Values.verticalPodAutoscaler.resourcePolicy }}
  resourcePolicy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
