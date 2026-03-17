{{/*
Renders the Istio RequestAuthentication objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioRequestAuthentications" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio RequestAuthentication as required */ -}}
  {{- $enabledIstioRequestAuthentications := (include "bjw-s.common.lib.istioRequestAuthentication.enabledIstioRequestAuthentications" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioRequestAuthentications -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioRequestAuthenticationObject := (include "bjw-s.common.lib.istioRequestAuthentication.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio RequestAuthentication class */ -}}
    {{- include "bjw-s.common.class.istioRequestAuthentication" (dict "rootContext" $ "object" $istioRequestAuthenticationObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
