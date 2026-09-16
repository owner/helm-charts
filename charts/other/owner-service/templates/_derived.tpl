{{/*
The derived values block: everything the chart computes from the service's
declared shape plus the cluster catalog.

This is the same extension point app-template uses - a `hardcodedValues` block
merged over the user's values - with a much larger block. templates/common.yaml
does the merging and owns the precedence.
*/}}
{{- define "owner-service.derivedValues" -}}
{{- $root := . -}}
{{- $fullname := include "owner-service.fullname" . -}}
{{- $svc := include "owner-service.serviceName" . -}}
{{- $c := .Values.cluster -}}
{{- $envv := .Values.env | default dict -}}
{{- $ing := dig .Values.ingress.scope dict ($c.ingress | default dict) -}}
{{- $host := "" -}}
{{- if ne .Values.ingress.scope "none" -}}{{- $host = include "owner-service.host" . -}}{{- end -}}
{{- $db := dict -}}
{{- if .Values.database.cluster -}}{{- $db = index $c.databases .Values.database.cluster -}}{{- end -}}
global:
  {{/* Collapses the common library's fullname to exactly the release name, so
       every derived resource name matches what Terraform already created. */}}
  nameOverride: {{ $fullname }}
  {{/* Without this, kubernetes_state.* metrics report service:N/A. */}}
  propagateGlobalMetadataToPods: true
  labels:
    tags.datadoghq.com/service: {{ $svc | quote }}
    tags.datadoghq.com/env: {{ $c.env | quote }}

{{- if .Values.tlsCompanion }}
{{/* ------------------------------------------------------------------------
     TLS companion Application: the cert-manager Certificate only, into the
     namespace where the shared ingress gateway pod reads its TLS secret.
     Nothing else renders - no workload, no Service, no ExternalSecret.
     ------------------------------------------------------------------------ */}}
rawResources:
  certificate:
    apiVersion: cert-manager.io/v1
    kind: Certificate
    forceRename: {{ include "owner-service.tlsSecretName" . }}
    {{/* The common library's rawResource `spec` is the whole document body
         below metadata, so the resource's own spec is nested one level. */}}
    spec:
      spec:
        {{/* Must keep matching the Gateway's credentialName, across two
             Applications. A rename here is delete-then-create. */}}
        secretName: {{ include "owner-service.tlsSecretName" . }}
        issuerRef:
          kind: ClusterIssuer
          name: {{ required "cluster.ingress.<scope>.issuer is not set" $ing.issuer }}
        commonName: {{ $host | quote }}
        dnsNames:
          - {{ $host | quote }}

{{- else }}
{{/* ------------------------------------------------------------------------
     Controllers
     ------------------------------------------------------------------------ */}}
{{- $mainExtra := dict "APP_PORT" (printf "%v" .Values.port) "HOST" "0.0.0.0" }}
{{- if .Values.temporal.namespace }}
  {{- $_ := set $mainExtra "TEMPORAL_ENABLE_CLIENT" (printf "%v" .Values.temporal.client) }}
  {{- $_ := set $mainExtra "TEMPORAL_REGISTER_WORKER" "false" }}
{{- end }}
{{- $_ := set $mainExtra "DD_SERVICE" $svc }}
{{- $imageRepo := .Values.image.repository | default (printf "%s/%s" $c.imageRegistry $fullname) }}
{{/* A ServiceAccount name is only set when the workload needs AWS identity.
     Services with no datastore get the namespace default, which is also what
     lets the chart install on a bare test cluster where no SA exists. */}}
{{- $needsIdentity := false }}
{{- if .Values.database.cluster }}{{- $needsIdentity = true }}{{- end }}
{{- range $k, $v := (.Values.dependencies.aws | default dict) }}
  {{- if kindIs "map" $v }}{{- $needsIdentity = true }}{{- end }}
{{- end }}
controllers:
  main:
    replicas: {{ .Values.replicas }}
    strategy: RollingUpdate
    rollingUpdate:
      surge: 1
    {{- if $needsIdentity }}
    serviceAccount:
      {{/* Pod Identity is associated against this name in infra-v2. */}}
      name: {{ include "owner-service.serviceAccountName" . }}
    {{- end }}
    podDisruptionBudget:
      {{/* maxUnavailable, not minAvailable: stays correct if an HPA scales to 1. */}}
      maxUnavailable: 1
    annotations:
      reloader.stakater.com/auto: "true"
    pod:
      annotations:
        ad.datadoghq.com/main.logs: '[{"source":"{{ .Values.logSource }}","service":"{{ $svc }}"}]'
      securityContext:
        runAsNonRoot: true
        runAsUser: {{ $c.pod.runAsUser }}
        runAsGroup: {{ $c.pod.runAsGroup }}
        seccompProfile:
          type: RuntimeDefault
      terminationGracePeriodSeconds: {{ $c.pod.terminationGracePeriodSeconds }}
    containers:
      main:
        image:
          repository: {{ $imageRepo }}
          tag: {{ required "image.tag is not set - image-pin.yaml must load before values.yaml" .Values.image.tag | quote }}
          pullPolicy: {{ .Values.image.pullPolicy }}
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: [ALL]
        env:
          {{- include "owner-service.env.container" (dict "root" $root "appEnv" (dig "main" dict $envv) "extra" $mainExtra) | nindent 10 }}
        {{- if .Values.secretKeys }}
        envFrom:
          - secretRef:
              name: {{ include "owner-service.secretName" . }}
        {{- end }}
        probes:
          liveness:
            enabled: true
            custom: true
            spec:
              {{- if .Values.health.livenessPath }}
              httpGet:
                path: {{ .Values.health.livenessPath }}
                port: {{ .Values.port }}
              {{- else }}
              {{/* No shallow endpoint: TCP, so an upstream blip does not kill
                   the pod. That is readiness' job. */}}
              tcpSocket:
                port: {{ .Values.port }}
              {{- end }}
              initialDelaySeconds: 15
              periodSeconds: 15
              failureThreshold: 3
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: {{ .Values.health.readinessPath }}
                port: {{ .Values.port }}
              {{/* Dead config while a startup probe exists - kept so removing
                   the startup probe does not silently change readiness. */}}
              initialDelaySeconds: 10
              periodSeconds: 10
              failureThreshold: 3
          startup:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: {{ .Values.health.readinessPath }}
                port: {{ .Values.port }}
              periodSeconds: 5
              failureThreshold: {{ div .Values.health.startupBudgetSeconds 5 }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}

{{- range $name, $w := .Values.workers }}
{{- $wSvc := printf "%s-%s" $svc $name }}
{{- $auto := dig "autoscaling" dict $w }}
{{- $wExtra := dict "DD_SERVICE" $wSvc "APPLICATION_RUNTIME" (dig "runtime" "temporal-worker" $w) }}
{{- if $root.Values.temporal.namespace }}
  {{- $_ := set $wExtra "TEMPORAL_ENABLE_CLIENT" "true" }}
  {{- $_ := set $wExtra "TEMPORAL_REGISTER_WORKER" "true" }}
{{- end }}
  {{ $name }}:
    {{- if $auto.queue }}
    {{/* The ScaledObject owns replicas; omit spec.replicas from the Deployment. */}}
    replicas: null
    {{- else }}
    replicas: {{ dig "replicas" 1 $w }}
    {{- end }}
    strategy: RollingUpdate
    rollingUpdate:
      surge: 1
    labels:
      {{/* Override the global service label so kube-state-metrics reports this
           worker's replica status under its own service. */}}
      tags.datadoghq.com/service: {{ $wSvc | quote }}
      tags.datadoghq.com/env: {{ $c.env | quote }}
    {{- if $needsIdentity }}
    serviceAccount:
      {{/* Same SA and Pod Identity as the API controller. */}}
      name: {{ include "owner-service.serviceAccountName" $root }}
    {{- end }}
    annotations:
      reloader.stakater.com/auto: "true"
    pod:
      labels:
        tags.datadoghq.com/service: {{ $wSvc | quote }}
        tags.datadoghq.com/env: {{ $c.env | quote }}
      annotations:
        ad.datadoghq.com/main.logs: '[{"source":"{{ $root.Values.logSource }}","service":"{{ $wSvc }}"}]'
        {{- if eq (dig "runtime" "temporal-worker" $w) "temporal-worker" }}
        ad.datadoghq.com/main.checks: |
          {
            "openmetrics": {
              "init_config": {},
              "instances": [
                {
                  "openmetrics_endpoint": "http://%%host%%:{{ $c.temporal.metricsPort }}/metrics",
                  "histogram_buckets_as_distributions": true,
                  "metrics": ["temporal_.*"]
                }
              ]
            }
          }
        {{- end }}
      securityContext:
        runAsNonRoot: true
        runAsUser: {{ $c.pod.runAsUser }}
        runAsGroup: {{ $c.pod.runAsGroup }}
        seccompProfile:
          type: RuntimeDefault
      terminationGracePeriodSeconds: {{ $c.pod.terminationGracePeriodSeconds }}
    containers:
      main:
        image:
          repository: {{ $imageRepo }}
          {{/* Lockstep with the API build: image-pin.yaml writes one tag. */}}
          tag: {{ $root.Values.image.tag | quote }}
          pullPolicy: {{ $root.Values.image.pullPolicy }}
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: [ALL]
        env:
          {{- include "owner-service.env.container" (dict "root" $root "appEnv" (dig "workers" $name dict $envv) "extra" $wExtra) | nindent 10 }}
        {{- if $root.Values.secretKeys }}
        envFrom:
          - secretRef:
              name: {{ include "owner-service.secretName" $root }}
        {{- end }}
        probes:
          {{- if eq (dig "runtime" "temporal-worker" $w) "temporal-worker" }}
          liveness:
            enabled: true
            custom: true
            spec:
              {{/* No HTTP server in the worker runtime. TCP-check the Temporal
                   metrics port, which is bound only when the worker registers. */}}
              tcpSocket:
                port: {{ $c.temporal.metricsPort }}
              initialDelaySeconds: 20
              periodSeconds: 15
              failureThreshold: 3
          {{- end }}
          {{/* The worker is not a Service target. */}}
          readiness:
            enabled: false
          startup:
            enabled: false
        resources:
          {{- toYaml (dig "resources" $root.Values.resources $w) | nindent 10 }}
{{- end }}

{{/* ------------------------------------------------------------------------
     Service
     ------------------------------------------------------------------------ */}}
service:
  main:
    controller: main
    type: ClusterIP
    ports:
      http:
        port: 80
        targetPort: {{ .Values.port }}

{{/* ------------------------------------------------------------------------
     Raw resources
     ------------------------------------------------------------------------ */}}
rawResources:
{{- if .Values.secretKeys }}
  external-secret:
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    forceRename: {{ include "owner-service.secretName" . }}
    annotations:
      argocd.argoproj.io/sync-wave: "-1"
    spec:
      spec:
        refreshInterval: 1h
        secretStoreRef:
          kind: {{ $c.secrets.storeKind }}
          name: {{ $c.secrets.storeName }}
        target:
          {{/* creationPolicy Owner: the ExternalSecret takes its Secret with it
               on delete, which is why the name is tier-4 excluded. */}}
          name: {{ include "owner-service.secretName" . }}
          creationPolicy: Owner
        {{/* Explicit per-key mapping, NOT `dataFrom extract`: the upstream
             secret can carry keys the app must not see - the live
             biz-enrich-service secret carries TEMPORAL_REGISTER_WORKER=true. */}}
        data:
          {{- range $key := .Values.secretKeys }}
          - secretKey: {{ $key }}
            remoteRef:
              key: {{ include "owner-service.secretPath" $root }}
              property: {{ $key }}
          {{- end }}
{{- end }}

  {{/* Scoped egress allow-list. The namespace is default-deny, so egress fails
       SILENTLY (as timeouts) without this. Port-scoped rather than IP-scoped
       because AWS endpoint IPs rotate. */}}
  egress:
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    forceRename: {{ $fullname }}-egress
    spec:
      spec:
        podSelector:
          matchLabels:
            app.kubernetes.io/name: {{ $fullname }}
        policyTypes: [Egress]
        egress:
          {{- range $svcName := .Values.dependencies.services }}
          {{- $entry := index $c.services $svcName }}
          {{/* Service port, pod port and istio HBONE. Applies to every
               controller - the podSelector is shared. */}}
          - to:
              - namespaceSelector:
                  matchLabels:
                    kubernetes.io/metadata.name: {{ $entry.namespace }}
                podSelector:
                  matchLabels:
                    app.kubernetes.io/name: {{ $svcName }}
            ports:
              - { port: {{ $entry.servicePort }}, protocol: TCP }
              - { port: {{ $entry.podPort }}, protocol: TCP }
              - { port: {{ $c.istio.mtlsPort }}, protocol: TCP }
          {{- end }}
          {{/* CoreDNS. */}}
          - to:
              - ipBlock: { cidr: 0.0.0.0/0 }
            ports:
              - { port: 53, protocol: UDP }
              - { port: 53, protocol: TCP }
          {{/* HTTPS: STS, DynamoDB, OpenSearch, Snowflake, other SaaS. */}}
          - to:
              - ipBlock: { cidr: 0.0.0.0/0 }
            ports:
              - { port: 443, protocol: TCP }
          {{- $peered := list }}
          {{- if $db }}{{- $peered = append $peered ($db.port | default 5432) }}{{- end }}
          {{- if .Values.temporal.namespace }}{{- $peered = append $peered (splitList ":" $c.temporal.host | last | int) }}{{- end }}
          {{- if $peered }}
          {{/* Postgres and the Temporal frontend are in the peered ECS VPC.
               Destinations are in-VPC, so there is no IP-rotation brittleness. */}}
          - to:
              - ipBlock: { cidr: {{ required "cluster.peeredVpcCidr is not set" $c.peeredVpcCidr }} }
            ports:
              {{- range $p := $peered }}
              - { port: {{ $p }}, protocol: TCP }
              {{- end }}
          {{- end }}
          {{- if .Values.cache.enabled }}
          {{/* ElastiCache, in this cluster's VPC, over TLS. */}}
          - to:
              - ipBlock: { cidr: {{ required "cluster.vpcCidr is not set" $c.vpcCidr }} }
            ports:
              - { port: {{ $c.cache.port }}, protocol: TCP }
          {{- end }}
          {{/* Datadog APM + dogstatsd at the node IP. */}}
          - to:
              - ipBlock: { cidr: 0.0.0.0/0 }
            ports:
              - { port: {{ $c.datadog.apmPort }}, protocol: TCP }
              - { port: {{ $c.datadog.statsdPort }}, protocol: UDP }
          {{/* AWS Pod Identity credentials endpoint (link-local, HTTP). */}}
          - to:
              - ipBlock: { cidr: {{ $c.podIdentityCidr }} }
            ports:
              - { port: 80, protocol: TCP }

{{- if ne .Values.ingress.scope "none" }}
  gateway:
    apiVersion: networking.istio.io/v1
    kind: Gateway
    forceRename: {{ include "owner-service.gatewayName" . }}
    annotations:
      external-dns.alpha.kubernetes.io/hostname: {{ $host | quote }}
      external-dns.alpha.kubernetes.io/visibility: {{ $ing.visibility }}
      {{/* Required: the public and private ingress gateways share the
           istio=ingressgateway label, so external-dns cannot resolve the
           target on its own and emits no record without this. */}}
      external-dns.alpha.kubernetes.io/target: {{ $ing.target }}
    spec:
      spec:
        selector:
          {{- toYaml $ing.selector | nindent 10 }}
        servers:
          - port:
              number: 443
              name: https
              protocol: HTTPS
            tls:
              mode: SIMPLE
              credentialName: {{ include "owner-service.tlsSecretName" . }}
            hosts:
              - {{ $host | quote }}
          - port:
              number: 80
              name: http
              protocol: HTTP
            tls:
              httpsRedirect: true
            hosts:
              - {{ $host | quote }}

  virtualservice:
    apiVersion: networking.istio.io/v1
    kind: VirtualService
    forceRename: {{ include "owner-service.gatewayName" . }}
    spec:
      spec:
        hosts:
          - {{ $host | quote }}
        gateways:
          - {{ include "owner-service.gatewayName" . }}
        http:
          - route:
              - destination:
                  host: {{ $fullname }}.{{ .Release.Namespace }}.svc.cluster.local
                  port:
                    number: 80
{{- end }}

{{- range $name, $w := .Values.workers }}
{{- $auto := dig "autoscaling" dict $w }}
{{- if $auto.queue }}
{{- $wSvc := printf "%s-%s" $svc $name }}
  {{ $name }}-scaled-object:
    apiVersion: keda.sh/v1alpha1
    kind: ScaledObject
    forceRename: {{ $fullname }}-{{ $name }}-backlog
    spec:
      spec:
        scaleTargetRef:
          name: {{ $fullname }}-{{ $name }}
        pollingInterval: 60
        cooldownPeriod: 600
        minReplicaCount: {{ dig "minReplicas" 1 $auto }}
        maxReplicaCount: {{ required "workers[].autoscaling.maxReplicas is required" $auto.maxReplicas }}
        triggers:
          - type: aws-cloudwatch
            metadata:
              namespace: Temporal/TaskQueue
              metricName: BacklogCount
              dimensionName: Cluster;Namespace;TaskQueue
              dimensionValue: {{ $c.temporal.cluster }};{{ $root.Values.temporal.namespace }};{{ $auto.queue }}
              targetMetricValue: {{ required "workers[].autoscaling.backlogPerReplica is required" $auto.backlogPerReplica | quote }}
              minMetricValue: "0"
              metricCollectionTime: "180"
              metricStatPeriod: "60"
              metricEndTimeOffset: "60"
              awsRegion: {{ $c.region }}
            authenticationRef:
              name: {{ $wSvc }}-cloudwatch

  {{ $name }}-cloudwatch-auth:
    apiVersion: keda.sh/v1alpha1
    kind: TriggerAuthentication
    forceRename: {{ $wSvc }}-cloudwatch
    spec:
      spec:
        podIdentity:
          provider: aws
          roleArn: {{ required "cluster.keda.triggerAuthRoleArn is not set" $c.keda.triggerAuthRoleArn }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
