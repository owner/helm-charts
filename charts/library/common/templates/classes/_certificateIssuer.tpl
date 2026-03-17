{{/*
This template serves as a blueprint for all certificate Issuer objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.certificateIssuer" -}}
  {{- $rootContext := .rootContext -}}
  {{- $certificateIssuerObject := .object -}}

  {{- $labels := merge
    ($certificateIssuerObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($certificateIssuerObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: {{ $certificateIssuerObject.name }}
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
spec: {{- tpl (toYaml $certificateIssuerObject.spec) $rootContext | nindent 2 }}
{{- end -}}
