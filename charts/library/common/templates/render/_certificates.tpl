{{/*
Renders the Certificate objects required by the chart.
*/}}
{{- define "bjw-s.common.render.certificates" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate certificates as required */ -}}
  {{- $enabledCertificates := (include "bjw-s.common.lib.certificate.enabledCertificates" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledCertificates -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $certificateObject := (include "bjw-s.common.lib.certificate.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the certificate class */ -}}
    {{- include "bjw-s.common.class.certificate" (dict "rootContext" $ "object" $certificateObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}