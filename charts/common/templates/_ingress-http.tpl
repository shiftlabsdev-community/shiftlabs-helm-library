{{/*
HTTP Ingress resource — Full HAProxy/NGINX support
*/}}
{{- define "common.ingress.http" -}}
{{- if and .Values.ingress .Values.ingress.enabled -}}
{{- $fullName := include "common.fullname" . -}}
{{- $svcPort := index .Values.service.ports 0 -}}
{{- $isHAProxy := eq (default "nginx" .Values.ingress.controllerType) "haproxy" -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.ingress.extraLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{- if $isHAProxy }}
    {{- /* ============ HAProxy Annotations ============ */ -}}
    {{- if .Values.ingress.ssl.redirect }}
    haproxy.org/ssl-redirect: "true"
    {{- end }}
    {{- if or .Values.ingress.securityHeaders.enabled .Values.ingress.cors.enabled }}
    haproxy.org/response-set-header: |
      {{- if .Values.ingress.securityHeaders.enabled }}
      {{- if .Values.ingress.securityHeaders.hsts }}
      Strict-Transport-Security "max-age={{ int .Values.ingress.securityHeaders.hstsMaxAge }}{{ if .Values.ingress.securityHeaders.hstsIncludeSubdomains }}; includeSubDomains{{ end }}{{ if .Values.ingress.securityHeaders.hstsPreload }}; preload{{ end }}"
      {{- end }}
      {{- if .Values.ingress.securityHeaders.frameOptions }}
      X-Frame-Options "{{ .Values.ingress.securityHeaders.frameOptions }}"
      {{- end }}
      {{- if .Values.ingress.securityHeaders.contentTypeNosniff }}
      X-Content-Type-Options "nosniff"
      {{- end }}
      {{- if .Values.ingress.securityHeaders.xssProtection }}
      X-XSS-Protection "{{ .Values.ingress.securityHeaders.xssProtection }}"
      {{- end }}
      {{- if .Values.ingress.securityHeaders.referrerPolicy }}
      Referrer-Policy "{{ .Values.ingress.securityHeaders.referrerPolicy }}"
      {{- end }}
      {{- if .Values.ingress.securityHeaders.csp }}
      Content-Security-Policy "{{ .Values.ingress.securityHeaders.csp }}"
      {{- end }}
      {{- end }}
      {{- if .Values.ingress.cors.enabled }}
      Access-Control-Allow-Origin "{{ .Values.ingress.cors.allowOrigin }}"
      Access-Control-Allow-Methods "{{ .Values.ingress.cors.allowMethods }}"
      Access-Control-Allow-Headers "{{ .Values.ingress.cors.allowHeaders }}"
      Access-Control-Allow-Credentials "{{ .Values.ingress.cors.allowCredentials }}"
      Access-Control-Max-Age "{{ .Values.ingress.cors.maxAge }}"
      {{- end }}
    {{- end }}
    {{- if .Values.ingress.proxy.connectTimeout }}
    haproxy.org/timeout-connect: {{ printf "%ss" (toString .Values.ingress.proxy.connectTimeout) | quote }}
    {{- end }}
    {{- if or .Values.ingress.proxy.readTimeout .Values.ingress.proxy.sendTimeout }}
    {{- $serverTimeout := max (int .Values.ingress.proxy.readTimeout) (int .Values.ingress.proxy.sendTimeout) }}
    haproxy.org/timeout-server: {{ printf "%ss" (toString $serverTimeout) | quote }}
    {{- end }}
    {{- if .Values.ingress.rateLimit.enabled }}
    haproxy.org/rate-limit-requests: {{ .Values.ingress.rateLimit.rps | quote }}
    haproxy.org/rate-limit-period: "1s"
    {{- end }}
    {{- if .Values.ingress.websocket.enabled }}
    haproxy.org/timeout-tunnel: "3600s"
    {{- end }}
    {{- else }}
    {{- /* ============ NGINX Annotations ============ */ -}}
    {{- if .Values.ingress.ssl.redirect }}
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    {{- end }}
    {{- if .Values.ingress.ssl.protocols }}
    nginx.ingress.kubernetes.io/ssl-protocols: {{ .Values.ingress.ssl.protocols | quote }}
    {{- end }}
    {{- if .Values.ingress.ssl.ciphers }}
    nginx.ingress.kubernetes.io/ssl-ciphers: {{ .Values.ingress.ssl.ciphers | quote }}
    {{- end }}
    {{- if .Values.ingress.securityHeaders.enabled }}
    {{- if .Values.ingress.securityHeaders.hsts }}
    nginx.ingress.kubernetes.io/hsts: "true"
    nginx.ingress.kubernetes.io/hsts-max-age: {{ int .Values.ingress.securityHeaders.hstsMaxAge | quote }}
    nginx.ingress.kubernetes.io/hsts-include-subdomains: {{ .Values.ingress.securityHeaders.hstsIncludeSubdomains | quote }}
    {{- if .Values.ingress.securityHeaders.hstsPreload }}
    nginx.ingress.kubernetes.io/hsts-preload: "true"
    {{- end }}
    {{- end }}
    {{- if .Values.ingress.securityHeaders.frameOptions }}
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Frame-Options: {{ .Values.ingress.securityHeaders.frameOptions }}";
      {{- if .Values.ingress.securityHeaders.contentTypeNosniff }}
      more_set_headers "X-Content-Type-Options: nosniff";
      {{- end }}
      {{- if .Values.ingress.securityHeaders.xssProtection }}
      more_set_headers "X-XSS-Protection: {{ .Values.ingress.securityHeaders.xssProtection }}";
      {{- end }}
      {{- if .Values.ingress.securityHeaders.referrerPolicy }}
      more_set_headers "Referrer-Policy: {{ .Values.ingress.securityHeaders.referrerPolicy }}";
      {{- end }}
      {{- if .Values.ingress.securityHeaders.csp }}
      more_set_headers "Content-Security-Policy: {{ .Values.ingress.securityHeaders.csp }}";
      {{- end }}
    {{- end }}
    {{- end }}
    {{- if .Values.ingress.proxy.bodySize }}
    nginx.ingress.kubernetes.io/proxy-body-size: {{ .Values.ingress.proxy.bodySize | quote }}
    {{- end }}
    {{- if .Values.ingress.proxy.connectTimeout }}
    nginx.ingress.kubernetes.io/proxy-connect-timeout: {{ .Values.ingress.proxy.connectTimeout | quote }}
    {{- end }}
    {{- if .Values.ingress.proxy.sendTimeout }}
    nginx.ingress.kubernetes.io/proxy-send-timeout: {{ .Values.ingress.proxy.sendTimeout | quote }}
    {{- end }}
    {{- if .Values.ingress.proxy.readTimeout }}
    nginx.ingress.kubernetes.io/proxy-read-timeout: {{ .Values.ingress.proxy.readTimeout | quote }}
    {{- end }}
    {{- if .Values.ingress.proxy.bufferSize }}
    nginx.ingress.kubernetes.io/proxy-buffer-size: {{ .Values.ingress.proxy.bufferSize | quote }}
    {{- end }}
    {{- if .Values.ingress.proxy.nextUpstream }}
    nginx.ingress.kubernetes.io/proxy-next-upstream: {{ .Values.ingress.proxy.nextUpstream | quote }}
    {{- end }}
    {{- if .Values.ingress.proxy.nextUpstreamTries }}
    nginx.ingress.kubernetes.io/proxy-next-upstream-tries: {{ .Values.ingress.proxy.nextUpstreamTries | quote }}
    {{- end }}
    {{- if .Values.ingress.rateLimit.enabled }}
    nginx.ingress.kubernetes.io/limit-rps: {{ .Values.ingress.rateLimit.rps | quote }}
    nginx.ingress.kubernetes.io/limit-burst-multiplier: {{ div .Values.ingress.rateLimit.burst .Values.ingress.rateLimit.rps | quote }}
    {{- end }}
    {{- if .Values.ingress.cors.enabled }}
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: {{ .Values.ingress.cors.allowOrigin | quote }}
    nginx.ingress.kubernetes.io/cors-allow-methods: {{ .Values.ingress.cors.allowMethods | quote }}
    nginx.ingress.kubernetes.io/cors-allow-headers: {{ .Values.ingress.cors.allowHeaders | quote }}
    nginx.ingress.kubernetes.io/cors-allow-credentials: {{ .Values.ingress.cors.allowCredentials | quote }}
    nginx.ingress.kubernetes.io/cors-max-age: {{ .Values.ingress.cors.maxAge | quote }}
    {{- end }}
    {{- if .Values.ingress.websocket.enabled }}
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/websocket-services: {{ $fullName }}
    {{- end }}
    {{- if .Values.ingress.canary.enabled }}
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: {{ .Values.ingress.canary.weight | quote }}
    {{- end }}
    {{- end }}
    {{- with .Values.ingress.extraAnnotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
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
