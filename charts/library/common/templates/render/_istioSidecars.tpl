{{/*
Renders the Istio Sidecar objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioSidecars" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio Sidecar as required */ -}}
  {{- $enabledIstioSidecars := (include "bjw-s.common.lib.istioSidecar.enabledIstioSidecars" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioSidecars -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioSidecarObject := (include "bjw-s.common.lib.istioSidecar.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio Sidecar class */ -}}
    {{- include "bjw-s.common.class.istioSidecar" (dict "rootContext" $ "object" $istioSidecarObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
