{{/*
Return the enabled ExternalSecrets.
*/}}
{{- define "bjw-s.common.lib.externalSecret.enabledExternalSecrets" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledExternalSecrets := dict -}}

  {{- range $name, $externalSecret := $rootContext.Values.externalSecrets -}}
    {{- if kindIs "map" $externalSecret -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $externalSecretEnabled := true -}}
      {{- if hasKey $externalSecret "enabled" -}}
        {{- $externalSecretEnabled = $externalSecret.enabled -}}
      {{- end -}}

      {{- if $externalSecretEnabled -}}
        {{- $_ := set $enabledExternalSecrets $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledExternalSecrets | toYaml -}}
{{- end -}}