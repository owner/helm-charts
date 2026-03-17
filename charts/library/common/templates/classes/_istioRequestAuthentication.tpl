{{/*
This template serves as a blueprint for all Istio RequestAuthentication objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.istioRequestAuthentication" -}}
  {{- $rootContext := .rootContext -}}
  {{- $istioRequestAuthenticationObject := .object -}}

  {{- $labels := merge
    ($istioRequestAuthenticationObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($istioRequestAuthenticationObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: security.istio.io/v1
kind: RequestAuthentication
metadata:
  name: {{ $istioRequestAuthenticationObject.name }}
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
  {{- with $istioRequestAuthenticationObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}
