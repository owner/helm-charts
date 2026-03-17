{{/*
Return the enabled Istio VirtualServices.
*/}}
{{- define "bjw-s.common.lib.istioVirtualService.enabledIstioVirtualServices" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioVirtualServices := dict -}}

  {{- range $name, $istioVirtualService := $rootContext.Values.istioVirtualServices -}}
    {{- if kindIs "map" $istioVirtualService -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioVirtualServiceEnabled := true -}}
      {{- if hasKey $istioVirtualService "enabled" -}}
        {{- $istioVirtualServiceEnabled = $istioVirtualService.enabled -}}
      {{- end -}}

      {{- if $istioVirtualServiceEnabled -}}
        {{- $_ := set $enabledIstioVirtualServices $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioVirtualServices | toYaml -}}
{{- end -}}
