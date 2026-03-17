{{/*
Return the enabled Istio PeerAuthentications.
*/}}
{{- define "bjw-s.common.lib.istioPeerAuthentication.enabledIstioPeerAuthentications" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioPeerAuthentications := dict -}}

  {{- range $name, $istioPeerAuthentication := $rootContext.Values.istioPeerAuthentications -}}
    {{- if kindIs "map" $istioPeerAuthentication -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioPeerAuthenticationEnabled := true -}}
      {{- if hasKey $istioPeerAuthentication "enabled" -}}
        {{- $istioPeerAuthenticationEnabled = $istioPeerAuthentication.enabled -}}
      {{- end -}}

      {{- if $istioPeerAuthenticationEnabled -}}
        {{- $_ := set $enabledIstioPeerAuthentications $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioPeerAuthentications | toYaml -}}
{{- end -}}
