{{/*
Renders the certificate ClusterIssuer objects required by the chart.
*/}}
{{- define "bjw-s.common.render.certificateClusterIssuers" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate certificate cluster issuers as required */ -}}
  {{- $enabledCertificateClusterIssuers := (include "bjw-s.common.lib.certificateClusterIssuer.enabledCertificateClusterIssuers" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledCertificateClusterIssuers -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $certificateClusterIssuerObject := (include "bjw-s.common.lib.certificateClusterIssuer.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the certificateClusterIssuer class */ -}}
    {{- include "bjw-s.common.class.certificateClusterIssuer" (dict "rootContext" $ "object" $certificateClusterIssuerObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
