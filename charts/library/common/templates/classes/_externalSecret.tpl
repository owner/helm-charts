{{/*
This template serves as a blueprint for all ExternalSecret objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.externalSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $externalSecretObject := .object -}}

  {{- $labels := merge
    ($externalSecretObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($externalSecretObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ $externalSecretObject.name }}
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
  {{- with $externalSecretObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}