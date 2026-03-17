How to deploy a web service with an ExternalSecret, Istio VirtualService, Gateway, AuthorizationPolicy, and a TLS Certificate.

This example demonstrates using native CRD keys instead of `rawResources` for a production service exposed through Istio with TLS termination.

```yaml linenums="1"
# =============================================================================
# Controller
# =============================================================================

controllers:
  main:
    replicas: 2
    serviceAccount:
      identifier: main
    pod:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
      terminationGracePeriodSeconds: 30
    containers:
      main:
        image:
          repository: my-registry.example.com/my-service
          tag: "abc123"
          pullPolicy: IfNotPresent
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: [ALL]
        env:
          NODE_ENV: production
          APP_PORT: "3000"
          DD_AGENT_HOST:
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
        envFrom:
          - secret: "{{ .Release.Name }}-secret"
        probes:
          liveness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: 3000
              initialDelaySeconds: 10
              periodSeconds: 10
              failureThreshold: 3
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: 3000
              initialDelaySeconds: 5
              periodSeconds: 5
              failureThreshold: 3
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            memory: 512Mi

# =============================================================================
# ServiceAccount & Service
# =============================================================================

serviceAccount:
  main:
    enabled: true

service:
  main:
    controller: main
    type: ClusterIP
    ports:
      http:
        port: 80
        targetPort: 3000

# =============================================================================
# ExternalSecret — pull secrets from a ClusterSecretStore
# =============================================================================

externalSecrets:
  main:
    spec:
      refreshInterval: 1h
      secretStoreRef:
        kind: ClusterSecretStore
        name: aws-secrets-manager
      target:
        name: "{{ .Release.Name }}-secret"
        creationPolicy: Owner
      data:
        - secretKey: DB_PASSWORD
          remoteRef:
            key: my-service/secrets
            property: db_password
        - secretKey: API_KEY
          remoteRef:
            key: my-service/secrets
            property: api_key

# =============================================================================
# Istio — Gateway, VirtualService, and AuthorizationPolicy
# =============================================================================

istioGateways:
  main:
    annotations:
      external-dns.alpha.kubernetes.io/hostname: my-service.example.com
    spec:
      selector:
        istio: ingressgateway
      servers:
        - hosts:
            - my-service.example.com
          port:
            name: https
            number: 443
            protocol: HTTPS
          tls:
            credentialName: my-service-tls
            mode: SIMPLE
        - hosts:
            - my-service.example.com
          port:
            name: http
            number: 80
            protocol: HTTP
          tls:
            httpsRedirect: true

istioVirtualServices:
  main:
    spec:
      hosts:
        - my-service.example.com
      gateways:
        - "{{ .Release.Name }}-gateway"
        - mesh
      http:
        - route:
            - destination:
                host: "{{ .Release.Name }}"
                port:
                  number: 80

istioAuthorizationPolicies:
  main:
    spec:
      selector:
        matchLabels:
          app.kubernetes.io/name: my-service
      action: ALLOW
      rules:
        - to:
            - operation:
                paths: ["/api/*", "/health"]

# =============================================================================
# TLS Certificate via cert-manager
# =============================================================================

certificates:
  main:
    spec:
      dnsNames:
        - my-service.example.com
      issuerRef:
        kind: ClusterIssuer
        name: letsencrypt-prod
      secretName: my-service-tls

# =============================================================================
# NetworkPolicy
# =============================================================================

networkpolicies:
  main:
    enabled: true
    controller: main
    policyTypes: [Ingress, Egress]
    rules:
      ingress:
        - from:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: istio-ingress
              podSelector:
                matchLabels:
                  istio: ingressgateway
      egress:
        - {}
```
