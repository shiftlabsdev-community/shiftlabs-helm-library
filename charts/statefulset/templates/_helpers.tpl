{{/* StatefulSet-specific aliases for common templates */}}
{{- define "statefulset.name" -}}{{- include "common.name" . -}}{{- end -}}
{{- define "statefulset.fullname" -}}{{- include "common.fullname" . -}}{{- end -}}
{{- define "statefulset.chart" -}}{{- include "common.chart" . -}}{{- end -}}
{{- define "statefulset.labels" -}}{{- include "common.labels" . -}}{{- end -}}
{{- define "statefulset.selectorLabels" -}}{{- include "common.selectorLabels" . -}}{{- end -}}
{{- define "statefulset.serviceAccountName" -}}{{- include "common.serviceAccountName" . -}}{{- end -}}
{{- define "statefulset.probe" -}}{{- include "common.probe" . -}}{{- end -}}
