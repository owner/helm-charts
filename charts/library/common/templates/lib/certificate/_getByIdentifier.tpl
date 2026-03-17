{{/*
Return a Certificate object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.certificate.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledCertificates := (include "bjw-s.common.lib.certificate.enabledCertificates" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledCertificates $identifier) -}}
    {{- $objectValues := get $enabledCertificates $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledCertificates)) -}}
  {{- end -}}
{{- end -}}
