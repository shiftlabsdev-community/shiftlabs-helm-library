{{/* CronJob-specific aliases for common templates */}}
{{- define "cronjob.name" -}}{{- include "common.name" . -}}{{- end -}}
{{- define "cronjob.fullname" -}}{{- include "common.fullname" . -}}{{- end -}}
{{- define "cronjob.chart" -}}{{- include "common.chart" . -}}{{- end -}}
{{- define "cronjob.labels" -}}{{- include "common.labels" . -}}{{- end -}}
{{- define "cronjob.selectorLabels" -}}{{- include "common.selectorLabels" . -}}{{- end -}}
{{- define "cronjob.serviceAccountName" -}}{{- include "common.serviceAccountName" . -}}{{- end -}}
