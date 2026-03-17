{{/*
Return the enabled certificate ClusterIssuers.
*/}}
{{- define "bjw-s.common.lib.certificateClusterIssuer.enabledCertificateClusterIssuers" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledCertificateClusterIssuers := dict -}}

  {{- range $name, $certificateClusterIssuer := $rootContext.Values.certificateClusterIssuers -}}
    {{- if kindIs "map" $certificateClusterIssuer -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $certificateClusterIssuerEnabled := true -}}
      {{- if hasKey $certificateClusterIssuer "enabled" -}}
        {{- $certificateClusterIssuerEnabled = $certificateClusterIssuer.enabled -}}
      {{- end -}}

      {{- if $certificateClusterIssuerEnabled -}}
        {{- $_ := set $enabledCertificateClusterIssuers $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledCertificateClusterIssuers | toYaml -}}
{{- end -}}
