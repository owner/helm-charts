{{/*
Return the enabled Istio Gateways.
*/}}
{{- define "bjw-s.common.lib.istioGateway.enabledIstioGateways" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioGateways := dict -}}

  {{- range $name, $istioGateway := $rootContext.Values.istioGateways -}}
    {{- if kindIs "map" $istioGateway -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioGatewayEnabled := true -}}
      {{- if hasKey $istioGateway "enabled" -}}
        {{- $istioGatewayEnabled = $istioGateway.enabled -}}
      {{- end -}}

      {{- if $istioGatewayEnabled -}}
        {{- $_ := set $enabledIstioGateways $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioGateways | toYaml -}}
{{- end -}}
