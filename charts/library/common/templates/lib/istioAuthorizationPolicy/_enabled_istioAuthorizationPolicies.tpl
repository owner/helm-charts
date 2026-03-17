{{/*
Return the enabled Istio AuthorizationPolicies.
*/}}
{{- define "bjw-s.common.lib.istioAuthorizationPolicy.enabledIstioAuthorizationPolicies" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledIstioAuthorizationPolicies := dict -}}

  {{- range $name, $istioAuthorizationPolicy := $rootContext.Values.istioAuthorizationPolicies -}}
    {{- if kindIs "map" $istioAuthorizationPolicy -}}
      {{- /* Enable by default, but allow override */ -}}
      {{- $istioAuthorizationPolicyEnabled := true -}}
      {{- if hasKey $istioAuthorizationPolicy "enabled" -}}
        {{- $istioAuthorizationPolicyEnabled = $istioAuthorizationPolicy.enabled -}}
      {{- end -}}

      {{- if $istioAuthorizationPolicyEnabled -}}
        {{- $_ := set $enabledIstioAuthorizationPolicies $name . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledIstioAuthorizationPolicies | toYaml -}}
{{- end -}}
