{{/*
Resource name for every object the chart renders.

We force `global.nameOverride` to the release name in the derived values, which
makes the common library's fullname collapse to exactly the release name. Every
derived name is built from this, so the naming convention the Terraform side
already implements is reproduced without reading any Terraform state.
*/}}
{{- define "owner-service.fullname" -}}
  {{- .Release.Name -}}
{{- end -}}

{{/* Datadog / UST service name. Not always the release name. */}}
{{- define "owner-service.serviceName" -}}
  {{- .Values.serviceName | default .Release.Name -}}
{{- end -}}

{{/* ServiceAccount name. Tier-4 excluded: this is identity, not configuration. */}}
{{- define "owner-service.serviceAccountName" -}}
  {{- printf "%s-%s" .Release.Name .Values.role -}}
{{- end -}}

{{/* Kubernetes Secret the ExternalSecret materialises. */}}
{{- define "owner-service.secretName" -}}
  {{- printf "%s-secret" .Release.Name -}}
{{- end -}}

{{/* Secrets Manager path. */}}
{{- define "owner-service.secretPath" -}}
  {{- printf "%s/%s" .Values.cluster.secrets.pathPrefix .Release.Name -}}
{{- end -}}

{{/* Ingress hostname. */}}
{{- define "owner-service.host" -}}
  {{- if .Values.ingress.host -}}
    {{- .Values.ingress.host -}}
  {{- else -}}
    {{- $scope := dig .Values.ingress.scope dict .Values.cluster.ingress -}}
    {{- printf "%s.%s" .Release.Name (required "cluster.ingress.<scope>.domain is not set for this cluster" $scope.domain) -}}
  {{- end -}}
{{- end -}}

{{/* Gateway / VirtualService / Certificate name. Tier-4 excluded. */}}
{{- define "owner-service.gatewayName" -}}
  {{- printf "%s-%s" .Release.Name .Values.ingress.scope -}}
{{- end -}}

{{/* Certificate secretName; must keep matching the Gateway credentialName. */}}
{{- define "owner-service.tlsSecretName" -}}
  {{- printf "%s-%s-tls" .Release.Name .Values.ingress.scope -}}
{{- end -}}

{{/* Resolved database entry from the cluster catalog. */}}
{{- define "owner-service.db" -}}
  {{- $entry := dig .Values.database.cluster dict .Values.cluster.databases -}}
  {{- $entry | toYaml -}}
{{- end -}}

{{/*
ElastiCache primary endpoint.

`cache.endpoint` wins - an acknowledged weak derivation, so the escape hatch is
first-class rather than a `raw:` block. Helm cannot resolve DNS, so there is no
render-time validator here; checking the composed host belongs to the pre-sync
conformance check.
*/}}
{{- define "owner-service.cacheHost" -}}
  {{- if .Values.cache.endpoint -}}
    {{- .Values.cache.endpoint -}}
  {{- else -}}
    {{- printf "master.%s.%s.%s.cache.amazonaws.com"
        (required "cache.name is required when cache.enabled is true" .Values.cache.name)
        (required "cluster.cache.hash is not set for this cluster" .Values.cluster.cache.hash)
        .Values.cluster.regionShort -}}
  {{- end -}}
{{- end -}}

{{/* Env-var prefix for an in-cluster dependency: auth-service -> AUTH_SERVICE */}}
{{- define "owner-service.envPrefix" -}}
  {{- . | upper | replace "-" "_" -}}
{{- end -}}
