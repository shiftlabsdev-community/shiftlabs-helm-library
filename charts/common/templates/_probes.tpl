{{/*
Probe configuration helper
Usage: include "common.probe" (dict "probe" .Values.probes.liveness "probeType" "liveness")
*/}}
{{- define "common.probe" -}}
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
