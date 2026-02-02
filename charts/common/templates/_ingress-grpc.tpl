{{/*
gRPC Ingress resource — Full HAProxy/NGINX support
*/}}
{{- define "common.ingress.grpc" -}}
{{- if and .Values.ingressGRPC .Values.ingressGRPC.enabled -}}
{{- $fullName := include "common.fullname" . -}}
{{- $svcPort := index .Values.service.ports 0 -}}
{{- $isHAProxy := eq (default "nginx" .Values.ingressGRPC.controllerType) "haproxy" -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}-grpc
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.ingressGRPC.extraLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{- if $isHAProxy }}
    haproxy.org/server-proto: "h2"
    {{- if and .Values.ingressGRPC.ssl .Values.ingressGRPC.ssl.redirect }}
    haproxy.org/ssl-redirect: "true"
    {{- end }}
    {{- if and .Values.ingressGRPC.securityHeaders .Values.ingressGRPC.securityHeaders.enabled }}
    haproxy.org/response-set-header: |
      {{- if .Values.ingressGRPC.securityHeaders.hsts }}
      Strict-Transport-Security "max-age={{ int .Values.ingressGRPC.securityHeaders.hstsMaxAge }}{{ if .Values.ingressGRPC.securityHeaders.hstsIncludeSubdomains }}; includeSubDomains{{ end }}{{ if .Values.ingressGRPC.securityHeaders.hstsPreload }}; preload{{ end }}"
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.frameOptions }}
      X-Frame-Options "{{ .Values.ingressGRPC.securityHeaders.frameOptions }}"
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.contentTypeNosniff }}
      X-Content-Type-Options "nosniff"
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.xssProtection }}
      X-XSS-Protection "{{ .Values.ingressGRPC.securityHeaders.xssProtection }}"
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.referrerPolicy }}
      Referrer-Policy "{{ .Values.ingressGRPC.securityHeaders.referrerPolicy }}"
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.csp }}
      Content-Security-Policy "{{ .Values.ingressGRPC.securityHeaders.csp }}"
      {{- end }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.connectTimeout }}
    haproxy.org/timeout-connect: {{ printf "%ss" (toString .Values.ingressGRPC.proxy.connectTimeout) | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy (or .Values.ingressGRPC.proxy.readTimeout .Values.ingressGRPC.proxy.sendTimeout) }}
    {{- $serverTimeout := max (int .Values.ingressGRPC.proxy.readTimeout) (int .Values.ingressGRPC.proxy.sendTimeout) }}
    haproxy.org/timeout-server: {{ printf "%ss" (toString $serverTimeout) | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.grpc .Values.ingressGRPC.grpc.timeout }}
    haproxy.org/timeout-tunnel: {{ printf "%ss" (toString .Values.ingressGRPC.grpc.timeout) | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.rateLimit .Values.ingressGRPC.rateLimit.enabled }}
    haproxy.org/rate-limit-requests: {{ .Values.ingressGRPC.rateLimit.rps | quote }}
    haproxy.org/rate-limit-period: "1s"
    {{- end }}
    {{- else }}
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
    {{- if and .Values.ingressGRPC.ssl .Values.ingressGRPC.ssl.redirect }}
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    {{- end }}
    {{- if and .Values.ingressGRPC.ssl .Values.ingressGRPC.ssl.protocols }}
    nginx.ingress.kubernetes.io/ssl-protocols: {{ .Values.ingressGRPC.ssl.protocols | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.ssl .Values.ingressGRPC.ssl.ciphers }}
    nginx.ingress.kubernetes.io/ssl-ciphers: {{ .Values.ingressGRPC.ssl.ciphers | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.securityHeaders .Values.ingressGRPC.securityHeaders.enabled }}
    {{- if .Values.ingressGRPC.securityHeaders.hsts }}
    nginx.ingress.kubernetes.io/hsts: "true"
    nginx.ingress.kubernetes.io/hsts-max-age: {{ int .Values.ingressGRPC.securityHeaders.hstsMaxAge | quote }}
    nginx.ingress.kubernetes.io/hsts-include-subdomains: {{ .Values.ingressGRPC.securityHeaders.hstsIncludeSubdomains | quote }}
    {{- if .Values.ingressGRPC.securityHeaders.hstsPreload }}
    nginx.ingress.kubernetes.io/hsts-preload: "true"
    {{- end }}
    {{- end }}
    {{- if or (and .Values.ingressGRPC.securityHeaders .Values.ingressGRPC.securityHeaders.frameOptions) (and .Values.ingressGRPC.grpc .Values.ingressGRPC.grpc.timeout) (and .Values.ingressGRPC.grpc .Values.ingressGRPC.grpc.maxMessageSize) }}
    nginx.ingress.kubernetes.io/configuration-snippet: |
      {{- if .Values.ingressGRPC.securityHeaders.frameOptions }}
      more_set_headers "X-Frame-Options: {{ .Values.ingressGRPC.securityHeaders.frameOptions }}";
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.contentTypeNosniff }}
      more_set_headers "X-Content-Type-Options: nosniff";
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.xssProtection }}
      more_set_headers "X-XSS-Protection: {{ .Values.ingressGRPC.securityHeaders.xssProtection }}";
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.referrerPolicy }}
      more_set_headers "Referrer-Policy: {{ .Values.ingressGRPC.securityHeaders.referrerPolicy }}";
      {{- end }}
      {{- if .Values.ingressGRPC.securityHeaders.csp }}
      more_set_headers "Content-Security-Policy: {{ .Values.ingressGRPC.securityHeaders.csp }}";
      {{- end }}
      {{- if and .Values.ingressGRPC.grpc .Values.ingressGRPC.grpc.timeout }}
      grpc_read_timeout {{ .Values.ingressGRPC.grpc.timeout }}s;
      grpc_send_timeout {{ .Values.ingressGRPC.grpc.timeout }}s;
      {{- end }}
      {{- if and .Values.ingressGRPC.grpc .Values.ingressGRPC.grpc.maxMessageSize }}
      client_max_body_size {{ .Values.ingressGRPC.grpc.maxMessageSize }};
      {{- end }}
    {{- end }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.bodySize }}
    nginx.ingress.kubernetes.io/proxy-body-size: {{ .Values.ingressGRPC.proxy.bodySize | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.connectTimeout }}
    nginx.ingress.kubernetes.io/proxy-connect-timeout: {{ .Values.ingressGRPC.proxy.connectTimeout | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.sendTimeout }}
    nginx.ingress.kubernetes.io/proxy-send-timeout: {{ .Values.ingressGRPC.proxy.sendTimeout | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.readTimeout }}
    nginx.ingress.kubernetes.io/proxy-read-timeout: {{ .Values.ingressGRPC.proxy.readTimeout | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.bufferSize }}
    nginx.ingress.kubernetes.io/proxy-buffer-size: {{ .Values.ingressGRPC.proxy.bufferSize | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.nextUpstream }}
    nginx.ingress.kubernetes.io/proxy-next-upstream: {{ .Values.ingressGRPC.proxy.nextUpstream | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.proxy .Values.ingressGRPC.proxy.nextUpstreamTries }}
    nginx.ingress.kubernetes.io/proxy-next-upstream-tries: {{ .Values.ingressGRPC.proxy.nextUpstreamTries | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.rateLimit .Values.ingressGRPC.rateLimit.enabled }}
    nginx.ingress.kubernetes.io/limit-rps: {{ .Values.ingressGRPC.rateLimit.rps | quote }}
    nginx.ingress.kubernetes.io/limit-burst-multiplier: {{ div .Values.ingressGRPC.rateLimit.burst .Values.ingressGRPC.rateLimit.rps | quote }}
    {{- end }}
    {{- if and .Values.ingressGRPC.canary .Values.ingressGRPC.canary.enabled }}
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: {{ .Values.ingressGRPC.canary.weight | quote }}
    {{- end }}
    {{- end }}
    {{- with .Values.ingressGRPC.extraAnnotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- if .Values.ingressGRPC.className }}
  ingressClassName: {{ .Values.ingressGRPC.className }}
  {{- end }}
  {{- if .Values.ingressGRPC.tls }}
  tls:
    {{- range .Values.ingressGRPC.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingressGRPC.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ dig "backend" "service" "name" $fullName . }}
                port:
                  number: {{ dig "backend" "service" "port" "number" $svcPort.port . }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}
