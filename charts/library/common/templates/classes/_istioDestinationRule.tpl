{{/*
This template serves as a blueprint for all Istio DestinationRule objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.istioDestinationRule" -}}
  {{- $rootContext := .rootContext -}}
  {{- $istioDestinationRuleObject := .object -}}

  {{- $labels := merge
    ($istioDestinationRuleObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($istioDestinationRuleObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: {{ $istioDestinationRuleObject.name }}
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
  {{- with $istioDestinationRuleObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}
