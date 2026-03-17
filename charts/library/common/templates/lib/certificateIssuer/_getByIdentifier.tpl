{{/*
Return a certificate Issuer object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.certificateIssuer.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledCertificateIssuers := (include "bjw-s.common.lib.certificateIssuer.enabledCertificateIssuers" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledCertificateIssuers $identifier) -}}
    {{- $objectValues := get $enabledCertificateIssuers $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledCertificateIssuers)) -}}
  {{- end -}}
{{- end -}}