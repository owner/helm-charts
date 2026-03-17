{{/*
Return the enabled certificate Issuers.
*/}}
{{- define "bjw-s.common.lib.certificateIssuer.enabledCertificateIssuers" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledCertificateIssuers := dict -}}

  {{- range $name, $certificateIssuer := $rootContext.Values.certificateIssuers -}}
    {{- if kindIs "map" $certificateIssuer -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $certificateIssuerEnabled := true -}}
      {{- if hasKey $certificateIssuer "enabled" -}}
        {{- $certificateIssuerEnabled = $certificateIssuer.enabled -}}
      {{- end -}}

      {{- if $certificateIssuerEnabled -}}
        {{- $_ := set $enabledCertificateIssuers $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledCertificateIssuers | toYaml -}}
{{- end -}}