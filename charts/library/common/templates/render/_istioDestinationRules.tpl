{{/*
Renders the Istio DestinationRule objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioDestinationRules" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio DestinationRule as required */ -}}
  {{- $enabledIstioDestinationRules := (include "bjw-s.common.lib.istioDestinationRule.enabledIstioDestinationRules" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioDestinationRules -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioDestinationRuleObject := (include "bjw-s.common.lib.istioDestinationRule.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio DestinationRule class */ -}}
    {{- include "bjw-s.common.class.istioDestinationRule" (dict "rootContext" $ "object" $istioDestinationRuleObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
