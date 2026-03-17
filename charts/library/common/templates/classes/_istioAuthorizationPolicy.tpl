{{/*
This template serves as a blueprint for all Istio AuthorizationPolicy objects that are created
within the common library.
*/}}
{{- define "bjw-s.common.class.istioAuthorizationPolicy" -}}
  {{- $rootContext := .rootContext -}}
  {{- $istioAuthorizationPolicyObject := .object -}}

  {{- $labels := merge
    ($istioAuthorizationPolicyObject.labels | default dict)
    (include "bjw-s.common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($istioAuthorizationPolicyObject.annotations | default dict)
    (include "bjw-s.common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: {{ $istioAuthorizationPolicyObject.name }}
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
  {{- with $istioAuthorizationPolicyObject.spec }}
spec:
    {{- tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end }}
{{- end -}}
