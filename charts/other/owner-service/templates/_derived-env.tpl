{{/*
Platform environment shared by every container in the release.

This is tier 3. It is computed from the cluster catalog plus the service's
declared shape, and it wins over anything an app writes in env.yaml - which is
why every key here is in the reserved list.
*/}}
{{- define "owner-service.env.platform" -}}
  {{- $e := dict -}}
  {{- $c := .Values.cluster -}}

  {{/* --- Database: RDS IAM auth, no password in git --- */}}
  {{- with .Values.database.cluster -}}
    {{- $db := index $.Values.cluster.databases . -}}
    {{- $role := $.Values.database.role | default $.Values.role -}}
    {{- $_ := set $e "DB_HOST" $db.host -}}
    {{- $_ := set $e "DB_READ_HOST" $db.readHost -}}
    {{- $_ := set $e "DB_PORT" (printf "%v" ($db.port | default 5432)) -}}
    {{- $_ := set $e "DB_USER" (printf "%s_%s" ($.Release.Name | replace "-" "_") $role) -}}
    {{- $_ := set $e "DB_NAME" $.Values.database.name -}}
    {{- $_ := set $e "USE_IAM_AUTH" "true" -}}
    {{/* Cross-account RDS IAM: the cluster catalog names the account the
         database lives in, and the runtime assumes this role before signing so
         the token appears same-account (rdsauthproxy rejects cross-account
         signatures). */}}
    {{- $_ := set $e "RDS_IAM_ASSUME_ROLE_ARN" (printf "arn:aws:iam::%s:role/%s-rds-connect" ($db.account | toString) (include "owner-service.serviceAccountName" $)) -}}
  {{- end -}}

  {{/* --- Cache --- */}}
  {{- if .Values.cache.enabled -}}
    {{- $_ := set $e "REDIS_HOST" (include "owner-service.cacheHost" .) -}}
    {{- $_ := set $e "REDIS_PORT" (printf "%v" $c.cache.port) -}}
    {{- $_ := set $e "REDIS_TLS" (printf "%v" $c.cache.tls) -}}
  {{- end -}}

  {{/* --- Temporal --- */}}
  {{- with .Values.temporal.namespace -}}
    {{- $t := $.Values.cluster.temporal -}}
    {{- $_ := set $e "TEMPORAL_HOST" $t.host -}}
    {{- $_ := set $e "TEMPORAL_ENABLE_CLIENT" "true" -}}
    {{- $_ := set $e "TEMPORAL_NAMESPACE" . -}}
    {{- $_ := set $e "TEMPORAL_DEFAULT_TASK_QUEUE" $.Values.temporal.taskQueue -}}
    {{- $_ := set $e "TEMPORAL_USE_TLS" (printf "%v" $t.tls) -}}
    {{- $_ := set $e "TEMPORAL_AUTO_CREATE_NAMESPACE" "false" -}}
    {{- $_ := set $e "TEMPORAL_NAMESPACE_WF_RETENTION_DAYS" (printf "%v" $t.retentionDays) -}}
    {{- $_ := set $e "TEMPORAL_PROMETHEUS_PORT" (printf "%v" $t.metricsPort) -}}
  {{- end -}}

  {{/* --- In-cluster dependencies: ClusterIP, istio mTLS transparent. Avoids
         hairpinning out to the external hostname. --- */}}
  {{- range $svc := .Values.dependencies.services -}}
    {{- $entry := index $c.services $svc -}}
    {{- $_ := set $e (printf "%s_URL" (include "owner-service.envPrefix" $svc)) $entry.url -}}
  {{- end -}}

  {{/* --- AWS --- */}}
  {{- $aws := .Values.dependencies.aws | default dict -}}
  {{- if kindIs "map" (get $aws "dynamodb") -}}
    {{- $_ := set $e "DYNAMODB_ASSUME_ROLE_ARN" (printf "arn:aws:iam::%s:role/%s-dynamodb" ($c.crossAccount | toString) (include "owner-service.serviceAccountName" .)) -}}
  {{- end -}}
  {{- with get $aws "opensearch" -}}
    {{- if .domain -}}
      {{- $_ := set $e "OPENSEARCH_ENDPOINT" (index $c.opensearch.domains .domain).endpoint -}}
    {{- end -}}
  {{- end -}}

  {{/* --- Datadog. DD_SERVICE is set per-controller. --- */}}
  {{- $_ := set $e "DD_AGENT_HOST" (dict "valueFrom" (dict "fieldRef" (dict "fieldPath" "status.hostIP"))) -}}
  {{- $_ := set $e "DD_ENV" $c.env -}}
  {{- $_ := set $e "DD_VERSION" (printf "%v" .Values.image.tag) -}}
  {{- $_ := set $e "DD_TRACE_AGENT_PROTOCOL_VERSION" "0.5" -}}
  {{- $_ := set $e "DD_LOGS_INJECTION" "true" -}}
  {{- $_ := set $e "DD_PROFILING_ENABLED" "true" -}}
  {{- $_ := set $e "DD_PROFILING_CODEHOTSPOTS_ENABLED" "true" -}}
  {{- $_ := set $e "DD_PROFILING_ENDPOINT_COLLECTION_ENABLED" "true" -}}
  {{- $_ := set $e "DD_RUNTIME_METRICS_ENABLED" "true" -}}
  {{- if .Values.database.cluster -}}
    {{- $_ := set $e "DD_DBM_PROPAGATION_MODE" "full" -}}
  {{- end -}}

  {{- $e | toYaml -}}
{{- end -}}

{{/*
Final env for a single container.

Merge order is the whole point: app values first, platform derivation last.

    env.shared  <  env.<container>  <  platform derivation

The validator makes the last step unreachable in practice - an app cannot write
a reserved key - so this is belt and braces rather than a silent override.
*/}}
{{- define "owner-service.env.container" -}}
  {{- $root := .root -}}
  {{- $app := merge (deepCopy .appEnv) (deepCopy (dig "shared" dict $root.Values.env)) -}}
  {{- $platform := merge (deepCopy .extra) (include "owner-service.env.platform" $root | fromYaml) -}}
  {{- mustMergeOverwrite $app $platform | toYaml -}}
{{- end -}}
