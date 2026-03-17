{{/*
This template serves as a blueprint for all Istio PeerAuthentication objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.istioPeerAuthentication" -}}
  {{- $rootContext := .rootContext -}}
  {{- $istioPeerAuthenticationObject := .object -}}

  {{- $labels := merge
    ($istioPeerAuthenticationObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($istioPeerAuthenticationObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: {{ $istioPeerAuthenticationObject.name }}
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
  {{- with $istioPeerAuthenticationObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}
