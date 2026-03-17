{{/*
Return an Istio VirtualService object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioVirtualService.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioVirtualServices := (include "bjw-s.common.lib.istioVirtualService.enabledIstioVirtualServices" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioVirtualServices $identifier) -}}
    {{- $objectValues := get $enabledIstioVirtualServices $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioVirtualServices)) -}}
  {{- end -}}
{{- end -}}
