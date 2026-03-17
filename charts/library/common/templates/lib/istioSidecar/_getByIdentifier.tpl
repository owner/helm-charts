{{/*
Return an Istio Sidecar object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioSidecar.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioSidecars := (include "bjw-s.common.lib.istioSidecar.enabledIstioSidecars" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioSidecars $identifier) -}}
    {{- $objectValues := get $enabledIstioSidecars $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioSidecars)) -}}
  {{- end -}}
{{- end -}}
