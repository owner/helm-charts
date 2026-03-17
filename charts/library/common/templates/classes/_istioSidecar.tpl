{{/*
This template serves as a blueprint for all Istio Sidecar objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.istioSidecar" -}}
  {{- $rootContext := .rootContext -}}
  {{- $istioSidecarObject := .object -}}

  {{- $labels := merge
    ($istioSidecarObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($istioSidecarObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: {{ $istioSidecarObject.name }}
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
  {{- with $istioSidecarObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}
