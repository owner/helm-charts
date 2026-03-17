{{/*
Renders the Istio AuthorizationPolicy objects required by the chart.
*/}}
{{- define "bjw-s.common.render.istioAuthorizationPolicies" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate Istio AuthorizationPolicy as required */ -}}
  {{- $enabledIstioAuthorizationPolicies := (include "bjw-s.common.lib.istioAuthorizationPolicy.enabledIstioAuthorizationPolicies" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledIstioAuthorizationPolicies -}}
    {{- /* Generate object from the raw values */ -}}
    {{- $istioAuthorizationPolicyObject := (include "bjw-s.common.lib.istioAuthorizationPolicy.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Istio AuthorizationPolicy class */ -}}
    {{- include "bjw-s.common.class.istioAuthorizationPolicy" (dict "rootContext" $ "object" $istioAuthorizationPolicyObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
