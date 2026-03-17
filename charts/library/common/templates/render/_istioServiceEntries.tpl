{{/*
Renders the Istio ServiceEntry objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioServiceEntries" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio ServiceEntry as required */ -}}
  {{- $enabledIstioServiceEntries := (include "bjw-s.common.lib.istioServiceEntry.enabledIstioServiceEntries" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioServiceEntries -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioServiceEntryObject := (include "bjw-s.common.lib.istioServiceEntry.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio ServiceEntry class */ -}}
    {{- include "bjw-s.common.class.istioServiceEntry" (dict "rootContext" $ "object" $istioServiceEntryObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
