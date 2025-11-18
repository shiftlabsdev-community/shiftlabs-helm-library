{{/*
Expand the name of the chart.
*/}}
{{- define "daemonset.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "daemonset.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "daemonset.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "daemonset.labels" -}}
helm.sh/chart: {{ include "daemonset.chart" . }}
{{ include "daemonset.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "daemonset.selectorLabels" -}}
app.kubernetes.io/name: {{ include "daemonset.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "daemonset.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "daemonset.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Probe configuration helper
Usage: include "daemonset.probe" (dict "probe" .Values.probes.liveness "probeType" "liveness")
*/}}
{{- define "daemonset.probe" -}}
{{- $probe := .probe -}}
{{- $probeType := .probeType -}}
{{- if $probe.enabled -}}
{{ $probeType }}Probe:
  {{- if eq $probe.type "http" }}
  httpGet:
    path: {{ $probe.http.path }}
    port: {{ $probe.http.port }}
    scheme: {{ $probe.http.scheme | default "HTTP" }}
    {{- with $probe.http.httpHeaders }}
    httpHeaders:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else if eq $probe.type "tcp" }}
  tcpSocket:
    port: {{ $probe.tcp.port }}
  {{- else if eq $probe.type "grpc" }}
  grpc:
    port: {{ $probe.grpc.port }}
    {{- if $probe.grpc.service }}
    service: {{ $probe.grpc.service }}
    {{- end }}
  {{- else if eq $probe.type "exec" }}
  exec:
    command:
      {{- toYaml $probe.exec.command | nindent 6 }}
  {{- end }}
  initialDelaySeconds: {{ $probe.initialDelaySeconds }}
  periodSeconds: {{ $probe.periodSeconds }}
  timeoutSeconds: {{ $probe.timeoutSeconds }}
  failureThreshold: {{ $probe.failureThreshold }}
  successThreshold: {{ $probe.successThreshold }}
{{- end }}
{{- end }}
