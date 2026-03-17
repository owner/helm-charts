{{/*
Renders the Istio Gateway objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioGateways" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio Gateway as required */ -}}
  {{- $enabledIstioGateways := (include "bjw-s.common.lib.istioGateway.enabledIstioGateways" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioGateways -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioGatewayObject := (include "bjw-s.common.lib.istioGateway.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio Gateway class */ -}}
    {{- include "bjw-s.common.class.istioGateway" (dict "rootContext" $ "object" $istioGatewayObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
