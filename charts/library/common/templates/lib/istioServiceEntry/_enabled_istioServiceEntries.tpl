{{/*
Return the enabled Istio ServiceEntries.
*/}}
{{- define "bjw-s.common.lib.istioServiceEntry.enabledIstioServiceEntries" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioServiceEntries := dict -}}

  {{- range $name, $istioServiceEntry := $rootContext.Values.istioServiceEntries -}}
    {{- if kindIs "map" $istioServiceEntry -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioServiceEntryEnabled := true -}}
      {{- if hasKey $istioServiceEntry "enabled" -}}
        {{- $istioServiceEntryEnabled = $istioServiceEntry.enabled -}}
      {{- end -}}

      {{- if $istioServiceEntryEnabled -}}
        {{- $_ := set $enabledIstioServiceEntries $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioServiceEntries | toYaml -}}
{{- end -}}
