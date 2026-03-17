{{/*
This template serves as a blueprint for all Certificate objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.certificate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $certificateObject := .object -}}

  {{- $labels := merge
    ($certificateObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($certificateObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ $certificateObject.name }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  namespace: {{ $rootContext.Release.Namespace }}
spec: {{- tpl (toYaml $certificateObject.spec) $rootContext | nindent 2 }}
{{- end -}}
