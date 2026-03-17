{{/*
Return an Istio DestinationRule object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioDestinationRule.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioDestinationRules := (include "bjw-s.common.lib.istioDestinationRule.enabledIstioDestinationRules" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioDestinationRules $identifier) -}}
    {{- $objectValues := get $enabledIstioDestinationRules $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioDestinationRules)) -}}
  {{- end -}}
{{- end -}}
