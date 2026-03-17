{{/*
Return an Istio Gateway object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioGateway.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioGateways := (include "bjw-s.common.lib.istioGateway.enabledIstioGateways" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioGateways $identifier) -}}
    {{- $objectValues := get $enabledIstioGateways $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioGateways)) -}}
  {{- end -}}
{{- end -}}
