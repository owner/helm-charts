{{/*
Return an Istio AuthorizationPolicy object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioAuthorizationPolicy.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioAuthorizationPolicies := (include "bjw-s.common.lib.istioAuthorizationPolicy.enabledIstioAuthorizationPolicies" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioAuthorizationPolicies $identifier) -}}
    {{- $objectValues := get $enabledIstioAuthorizationPolicies $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioAuthorizationPolicies)) -}}
  {{- end -}}
{{- end -}}
