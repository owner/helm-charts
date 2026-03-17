{{/*
Return a certificate ClusterIssuer object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.certificateClusterIssuer.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledCertificateClusterIssuers := (include "bjw-s.common.lib.certificateClusterIssuer.enabledCertificateClusterIssuers" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledCertificateClusterIssuers $identifier) -}}
    {{- $objectValues := get $enabledCertificateClusterIssuers $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledCertificateClusterIssuers)) -}}
  {{- end -}}
{{- end -}}
