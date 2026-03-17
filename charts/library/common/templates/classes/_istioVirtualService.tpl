{{/*
This template serves as a blueprint for all Istio VirtualService objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.istioVirtualService" -}}
  {{- $rootContext := .rootContext -}}
  {{- $istioVirtualServiceObject := .object -}}

  {{- $labels := merge
    ($istioVirtualServiceObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($istioVirtualServiceObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: {{ $istioVirtualServiceObject.name }}
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
  {{- with $istioVirtualServiceObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}
