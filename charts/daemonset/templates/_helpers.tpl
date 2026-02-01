{{/* DaemonSet-specific aliases for common templates */}}
{{- define "daemonset.name" -}}{{- include "common.name" . -}}{{- end -}}
{{- define "daemonset.fullname" -}}{{- include "common.fullname" . -}}{{- end -}}
{{- define "daemonset.chart" -}}{{- include "common.chart" . -}}{{- end -}}
{{- define "daemonset.labels" -}}{{- include "common.labels" . -}}{{- end -}}
{{- define "daemonset.selectorLabels" -}}{{- include "common.selectorLabels" . -}}{{- end -}}
{{- define "daemonset.serviceAccountName" -}}{{- include "common.serviceAccountName" . -}}{{- end -}}
{{- define "daemonset.probe" -}}{{- include "common.probe" . -}}{{- end -}}
