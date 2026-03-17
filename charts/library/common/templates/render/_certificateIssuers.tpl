{{/*
Renders the certificate Issuer objects required by the chart.
*/}}
{{- define "bjw-s.common.render.certificateIssuers" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate certificate issuers as required */ -}}
  {{- $enabledCertificateIssuers := (include "bjw-s.common.lib.certificateIssuer.enabledCertificateIssuers" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledCertificateIssuers -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $certificateIssuerObject := (include "bjw-s.common.lib.certificateIssuer.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the certificateIssuer class */ -}}
    {{- include "bjw-s.common.class.certificateIssuer" (dict "rootContext" $ "object" $certificateIssuerObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
