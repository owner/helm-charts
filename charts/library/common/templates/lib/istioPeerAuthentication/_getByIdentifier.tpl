{{/*
Return an Istio PeerAuthentication object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioPeerAuthentication.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioPeerAuthentications := (include "bjw-s.common.lib.istioPeerAuthentication.enabledIstioPeerAuthentications" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioPeerAuthentications $identifier) -}}
    {{- $objectValues := get $enabledIstioPeerAuthentications $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioPeerAuthentications)) -}}
  {{- end -}}
{{- end -}}
