{{/*
Renders the Istio VirtualService objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioVirtualServices" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio VirtualService as required */ -}}
  {{- $enabledIstioVirtualServices := (include "bjw-s.common.lib.istioVirtualService.enabledIstioVirtualServices" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioVirtualServices -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioVirtualServiceObject := (include "bjw-s.common.lib.istioVirtualService.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio VirtualService class */ -}}
    {{- include "bjw-s.common.class.istioVirtualService" (dict "rootContext" $ "object" $istioVirtualServiceObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
