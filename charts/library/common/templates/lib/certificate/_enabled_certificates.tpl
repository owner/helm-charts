{{/*
Return the enabled Certificates.
*/}}
{{- define "bjw-s.common.lib.certificate.enabledCertificates" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledCertificates := dict -}}

  {{- range $name, $certificate := $rootContext.Values.certificates -}}
    {{- if kindIs "map" $certificate -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $certificateEnabled := true -}}
      {{- if hasKey $certificate "enabled" -}}
        {{- $certificateEnabled = $certificate.enabled -}}
      {{- end -}}

      {{- if $certificateEnabled -}}
        {{- $_ := set $enabledCertificates $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledCertificates | toYaml -}}
{{- end -}}
