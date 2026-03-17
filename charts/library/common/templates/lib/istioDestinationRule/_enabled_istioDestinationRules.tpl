{{/*
Return the enabled Istio DestinationRules.
*/}}
{{- define "bjw-s.common.lib.istioDestinationRule.enabledIstioDestinationRules" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioDestinationRules := dict -}}

  {{- range $name, $istioDestinationRule := $rootContext.Values.istioDestinationRules -}}
    {{- if kindIs "map" $istioDestinationRule -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioDestinationRuleEnabled := true -}}
      {{- if hasKey $istioDestinationRule "enabled" -}}
        {{- $istioDestinationRuleEnabled = $istioDestinationRule.enabled -}}
      {{- end -}}

      {{- if $istioDestinationRuleEnabled -}}
        {{- $_ := set $enabledIstioDestinationRules $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioDestinationRules | toYaml -}}
{{- end -}}
