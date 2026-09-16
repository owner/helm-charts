{{/*
Reserved environment variables.

This list must mechanically equal the set the chart derives - if a key is
derived, an app cannot hand-write it, because the derivation would silently win
and the values file would lie about what the pod sees. Per-dependency keys
(<SERVICE>_URL) are appended at validation time.
*/}}
{{- define "owner-service.reservedEnvKeys" -}}
  {{- $keys := list
    "APP_PORT" "HOST" "APPLICATION_RUNTIME"
    "DB_HOST" "DB_READ_HOST" "DB_PORT" "DB_USER" "DB_NAME" "USE_IAM_AUTH"
    "RDS_IAM_ASSUME_ROLE_ARN" "DYNAMODB_ASSUME_ROLE_ARN"
    "REDIS_HOST" "REDIS_PORT" "REDIS_TLS"
    "TEMPORAL_HOST" "TEMPORAL_ENABLE_CLIENT" "TEMPORAL_REGISTER_WORKER"
    "TEMPORAL_NAMESPACE" "TEMPORAL_DEFAULT_TASK_QUEUE" "TEMPORAL_USE_TLS"
    "TEMPORAL_AUTO_CREATE_NAMESPACE" "TEMPORAL_NAMESPACE_WF_RETENTION_DAYS"
    "TEMPORAL_PROMETHEUS_PORT"
    "OPENSEARCH_ENDPOINT"
    "DD_AGENT_HOST" "DD_SERVICE" "DD_ENV" "DD_VERSION"
  -}}
  {{- range $svc := .Values.dependencies.services -}}
    {{- $keys = append $keys (printf "%s_URL" (include "owner-service.envPrefix" $svc)) -}}
  {{- end -}}
  {{- $keys | toYaml -}}
{{- end -}}

{{/*
Identity fields `raw:` may not set.

These are identity, not configuration. A rename is delete-then-create, not a
restart: the ExternalSecret takes its Secret with it, a NetworkPolicy gap drops
all egress silently in a default-deny namespace, and the Certificate secretName
must keep matching the Gateway credentialName across two Applications.
*/}}
{{- define "owner-service.validateRaw" -}}
  {{- $raw := .Values.raw | default dict -}}

  {{- if hasKey $raw "controllers" -}}
    {{- fail "raw: may not set `controllers`. Use `archetype`, `workers:` and `resources:`; per-container tuning belongs in env.yaml." -}}
  {{- end -}}

  {{- range $id, $sa := (dig "serviceAccount" dict $raw) -}}
    {{- if and (kindIs "map" $sa) (hasKey $sa "name") -}}
      {{- fail "raw: may not set a ServiceAccount name. It is derived from the release name and `role`, and Pod Identity is associated against that name in infra-v2." -}}
    {{- end -}}
  {{- end -}}

  {{- range $id, $res := (dig "rawResources" dict $raw) -}}
    {{- if kindIs "map" $res -}}
      {{- $meta := dig "spec" "metadata" dict $res -}}
      {{- if hasKey $meta "name" -}}
        {{- fail (printf "raw.rawResources.%s may not set metadata.name. Resource names are identity; a rename is delete-then-create." $id) -}}
      {{- end -}}
      {{- if hasKey (dig "spec" "spec" dict $res) "target" -}}
        {{- fail (printf "raw.rawResources.%s may not set an ExternalSecret target. Use `secretKeys:`." $id) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- range $k, $_ := (dig "global" "labels" dict $raw) -}}
    {{- if hasPrefix "tags.datadoghq.com/" $k -}}
      {{- fail "raw: may not set UST labels. They derive from `serviceName` and `cluster.env`, which is what keeps monitor routing and review routing from drifting apart." -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* All render-time validation. Called before anything is derived. */}}
{{- define "owner-service.validate" -}}
  {{- $reserved := include "owner-service.reservedEnvKeys" . | fromYamlArray -}}

  {{/* 1. App-authored env may not collide with the derived set. */}}
  {{- $blocks := list (dig "shared" dict .Values.env) (dig "main" dict .Values.env) -}}
  {{- range $name, $block := (dig "workers" dict .Values.env) -}}
    {{- $blocks = append $blocks $block -}}
  {{- end -}}
  {{- range $block := $blocks -}}
    {{- range $key, $_ := $block -}}
      {{- if has $key $reserved -}}
        {{- fail (printf "env.%s is reserved: the chart derives it. Change the value that drives it instead, or use `raw:` with a comment saying why." $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* 2. The database cluster must be in the cluster catalog. */}}
  {{- if .Values.database.cluster -}}
    {{- if not (hasKey (.Values.cluster.databases | default dict) .Values.database.cluster) -}}
      {{- fail (printf "database.cluster %q is not in this cluster's catalog (%s). Add it to argocd/defaults/<cluster>.yaml rather than overriding the host - the catalog is what makes this a pre-deploy failure instead of a runtime one." .Values.database.cluster (keys (.Values.cluster.databases | default dict) | join ", ")) -}}
    {{- end -}}
    {{- if not .Values.database.name -}}
      {{- fail "database.name is required when database.cluster is set." -}}
    {{- end -}}
  {{- end -}}

  {{/* 3. Every in-cluster dependency must be in the cluster catalog. */}}
  {{- range $svc := .Values.dependencies.services -}}
    {{- if not (hasKey ($.Values.cluster.services | default dict) $svc) -}}
      {{- fail (printf "dependencies.services entry %q is not in this cluster's catalog. Without an entry the chart cannot derive its URL or its egress rule, and egress fails SILENTLY in a default-deny namespace." $svc) -}}
    {{- end -}}
  {{- end -}}

  {{/* 4. A named OpenSearch domain must be in the cluster catalog. */}}
  {{- with get (.Values.dependencies.aws | default dict) "opensearch" -}}
    {{- if .domain -}}
      {{- if not (hasKey (dig "opensearch" "domains" dict $.Values.cluster) .domain) -}}
        {{- fail (printf "dependencies.aws.opensearch.domain %q is not in this cluster's catalog. The VPC endpoint carries a random suffix, so it cannot be derived." .domain) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* 5. Queue autoscaling needs a Temporal namespace to build the metric dimension. */}}
  {{- range $name, $w := .Values.workers -}}
    {{- if dig "autoscaling" "queue" "" $w -}}
      {{- if not $.Values.temporal.namespace -}}
        {{- fail (printf "workers.%s.autoscaling.queue is set but temporal.namespace is not. The CloudWatch dimension is <cluster>;<namespace>;<queue>." $name) -}}
      {{- end -}}
      {{- if not (dig "keda" "triggerAuthRoleArn" "" $.Values.cluster) -}}
        {{- fail "workers[].autoscaling requires cluster.keda.triggerAuthRoleArn." -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* 6. The HTTP archetype needs a port. */}}
  {{- if and (eq .Values.archetype "http-api") (not .Values.tlsCompanion) (not .Values.port) -}}
    {{- fail "port is required for archetype http-api." -}}
  {{- end -}}

  {{/* 7. raw: may not reach into identity. */}}
  {{- include "owner-service.validateRaw" . -}}
{{- end -}}
