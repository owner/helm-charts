{{/*
Return the enabled Istio Sidecars.
*/}}
{{- define "bjw-s.common.lib.istioSidecar.enabledIstioSidecars" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioSidecars := dict -}}

  {{- range $name, $istioSidecar := $rootContext.Values.istioSidecars -}}
    {{- if kindIs "map" $istioSidecar -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioSidecarEnabled := true -}}
      {{- if hasKey $istioSidecar "enabled" -}}
        {{- $istioSidecarEnabled = $istioSidecar.enabled -}}
      {{- end -}}

      {{- if $istioSidecarEnabled -}}
        {{- $_ := set $enabledIstioSidecars $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioSidecars | toYaml -}}
{{- end -}}
