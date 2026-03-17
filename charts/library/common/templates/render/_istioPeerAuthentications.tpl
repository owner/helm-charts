{{/*
Renders the Istio PeerAuthentication objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioPeerAuthentications" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio PeerAuthentication as required */ -}}
  {{- $enabledIstioPeerAuthentications := (include "bjw-s.common.lib.istioPeerAuthentication.enabledIstioPeerAuthentications" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioPeerAuthentications -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioPeerAuthenticationObject := (include "bjw-s.common.lib.istioPeerAuthentication.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio PeerAuthentication class */ -}}
    {{- include "bjw-s.common.class.istioPeerAuthentication" (dict "rootContext" $ "object" $istioPeerAuthenticationObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
