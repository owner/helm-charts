{{/*
This template serves as a blueprint for all certificate ClusterIssuer objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.certificateClusterIssuer" -}}
  {{- $rootContext := .rootContext -}}
  {{- $certificateClusterIssuerObject := .object -}}

  {{- $labels := merge
    ($certificateClusterIssuerObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($certificateClusterIssuerObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: {{ $certificateClusterIssuerObject.name }}
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
spec: {{- tpl (toYaml $certificateClusterIssuerObject.spec) $rootContext | nindent 2 }}
{{- end -}}