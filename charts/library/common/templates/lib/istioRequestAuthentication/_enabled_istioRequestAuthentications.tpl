{{/*
Return the enabled Istio RequestAuthentications.
*/}}
{{- define "bjw-s.common.lib.istioRequestAuthentication.enabledIstioRequestAuthentications" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioRequestAuthentications := dict -}}

  {{- range $name, $istioRequestAuthentication := $rootContext.Values.istioRequestAuthentications -}}
    {{- if kindIs "map" $istioRequestAuthentication -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioRequestAuthenticationEnabled := true -}}
      {{- if hasKey $istioRequestAuthentication "enabled" -}}
        {{- $istioRequestAuthenticationEnabled = $istioRequestAuthentication.enabled -}}
      {{- end -}}

      {{- if $istioRequestAuthenticationEnabled -}}
        {{- $_ := set $enabledIstioRequestAuthentications $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioRequestAuthentications | toYaml -}}
{{- end -}}
