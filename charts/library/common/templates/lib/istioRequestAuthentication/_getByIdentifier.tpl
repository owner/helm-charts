{{/*
Return an Istio RequestAuthentication object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioRequestAuthentication.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioRequestAuthentications := (include "bjw-s.common.lib.istioRequestAuthentication.enabledIstioRequestAuthentications" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioRequestAuthentications $identifier) -}}
    {{- $objectValues := get $enabledIstioRequestAuthentications $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioRequestAuthentications)) -}}
  {{- end -}}
{{- end -}}
