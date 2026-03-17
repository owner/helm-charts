{{/*
Return an Istio ServiceEntry object by its Identifier.
*/}}
{{- define "bjw-s.common.lib.istioServiceEntry.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledIstioServiceEntries := (include "bjw-s.common.lib.istioServiceEntry.enabledIstioServiceEntries" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIstioServiceEntries $identifier) -}}
    {{- $objectValues := get $enabledIstioServiceEntries $identifier -}}
    {{- include "bjw-s.common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledIstioServiceEntries)) -}}
  {{- end -}}
{{- end -}}
