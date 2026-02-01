{{/* Deployment-specific aliases for common templates */}}
{{- define "deployment.name" -}}{{- include "common.name" . -}}{{- end -}}
{{- define "deployment.fullname" -}}{{- include "common.fullname" . -}}{{- end -}}
{{- define "deployment.chart" -}}{{- include "common.chart" . -}}{{- end -}}
{{- define "deployment.labels" -}}{{- include "common.labels" . -}}{{- end -}}
{{- define "deployment.selectorLabels" -}}{{- include "common.selectorLabels" . -}}{{- end -}}
{{- define "deployment.serviceAccountName" -}}{{- include "common.serviceAccountName" . -}}{{- end -}}
{{- define "deployment.probe" -}}{{- include "common.probe" . -}}{{- end -}}
