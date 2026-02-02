{{/*
HPA resource (native HPA + KEDA ScaledObject)
*/}}
{{- define "common.hpa" -}}
{{- if and .Values.autoscaling .Values.autoscaling.enabled (eq .Values.autoscaling.type "native") }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ .Values.autoscaling.targetKind | default "Deployment" }}
    name: {{ include "common.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
{{- end }}
{{- if and .Values.autoscaling .Values.autoscaling.enabled (eq .Values.autoscaling.type "keda") }}
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    name: {{ include "common.fullname" . }}
  minReplicaCount: {{ .Values.autoscaling.minReplicas }}
  maxReplicaCount: {{ .Values.autoscaling.maxReplicas }}
  triggers:
  {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
  - type: cpu
    metricType: Utilization
    metadata:
      value: "{{ .Values.autoscaling.targetCPUUtilizationPercentage }}"
  {{- end }}
  {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
  - type: memory
    metricType: Utilization
    metadata:
      value: "{{ .Values.autoscaling.targetMemoryUtilizationPercentage }}"
  {{- end }}
{{- end }}
{{- end }}
