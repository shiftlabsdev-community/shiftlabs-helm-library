{{/*
Test connection pod
*/}}
{{- define "common.test-connection" -}}
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "common.fullname" . }}-test-connection"
  labels:
    {{- include "common.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  containers:
    - name: wget
      image: busybox:1.35
      command: ['wget']
      args: ['{{ include "common.fullname" . }}:{{ (index .Values.service.ports 0).port }}']
  restartPolicy: Never
{{- end }}
