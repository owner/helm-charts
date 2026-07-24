{{- define "ownerforge-infra.fullname" -}}
{{- .Values.fullnameOverride | default .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ownerforge-infra.labels" -}}
app.kubernetes.io/name: {{ include "ownerforge-infra.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "ownerforge-infra.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ownerforge-infra.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "ownerforge-infra.scheduling" -}}
nodeSelector:
  {{- toYaml .Values.scheduling.nodeSelector | nindent 2 }}
tolerations:
  {{- toYaml .Values.scheduling.tolerations | nindent 2 }}
{{- end -}}
