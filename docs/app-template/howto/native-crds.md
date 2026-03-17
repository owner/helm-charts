# Native CRD Resources

The common library provides dedicated top-level keys for popular CRDs like ExternalSecrets, cert-manager Certificates, and Istio resources. These are a cleaner alternative to `rawResources` — the chart handles `apiVersion`, `kind`, and metadata automatically, and the `spec` is provided flat (no double nesting).

!!! info

    See **[CRD Resources](../../common-library/resources/crds.md)** for the full list of supported CRDs and their options.

## ExternalSecret

```yaml
externalSecrets:
  main:
    spec:
      refreshInterval: 1h
      secretStoreRef:
        kind: ClusterSecretStore
        name: onepassword
      target:
        name: "{{ .Release.Name }}-secret"
        creationPolicy: Owner
      data:
        - secretKey: DB_PASSWORD
          remoteRef:
            key: my-app/DB_PASSWORD
```

## Certificate

```yaml
certificates:
  main:
    spec:
      dnsNames:
        - myapp.example.com
      issuerRef:
        kind: ClusterIssuer
        name: letsencrypt-prod
      secretName: myapp-tls
```

## Istio VirtualService

```yaml
istioVirtualServices:
  main:
    spec:
      hosts:
        - myapp.example.com
      gateways:
        - istio-system/ingressgateway
      http:
        - match:
            - uri:
                prefix: /
          route:
            - destination:
                host: "{{ .Release.Name }}"
                port:
                  number: 80
```

## Istio Gateway

```yaml
istioGateways:
  main:
    annotations:
      external-dns.alpha.kubernetes.io/hostname: myapp.example.com
    spec:
      selector:
        istio: ingressgateway
      servers:
        - hosts:
            - myapp.example.com
          port:
            name: https
            number: 443
            protocol: HTTPS
          tls:
            credentialName: myapp-tls
            mode: SIMPLE
```

## Istio AuthorizationPolicy

```yaml
istioAuthorizationPolicies:
  main:
    spec:
      selector:
        matchLabels:
          app.kubernetes.io/name: my-app
      action: ALLOW
      rules:
        - to:
            - operation:
                paths: ["/api/*"]
```

## Multiple Resources of the Same Type

Multiple resources are defined as separate keys under the same top-level CRD key:

```yaml
externalSecrets:
  app-secrets:
    spec:
      refreshInterval: 1h
      secretStoreRef:
        kind: ClusterSecretStore
        name: onepassword
      target:
        name: "{{ .Release.Name }}-app-secrets"
        creationPolicy: Owner
      data:
        - secretKey: API_KEY
          remoteRef:
            key: my-app/API_KEY
  auth-secrets:
    spec:
      refreshInterval: 1h
      secretStoreRef:
        kind: ClusterSecretStore
        name: onepassword
      target:
        name: "{{ .Release.Name }}-auth-secrets"
        creationPolicy: Owner
      data:
        - secretKey: CLIENT_SECRET
          remoteRef:
            key: my-app/CLIENT_SECRET
```

## Migrating from rawResources

The conversion from `rawResources` to native CRD keys is straightforward:

1. Remove the `apiVersion` and `kind` fields (the chart handles these)
2. Move the inner `spec` up one level (remove the double nesting)
3. Keep `annotations`, `labels`, and `enabled` at the same level

### Before (rawResources)

```yaml
rawResources:
  secret:
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    spec:
      spec: # (1)!
        refreshInterval: 1h
        secretStoreRef:
          kind: ClusterSecretStore
          name: onepassword
        target:
          name: "{{ .Release.Name }}-secret"
          creationPolicy: Owner
        data:
          - secretKey: DB_PASSWORD
            remoteRef:
              key: my-app/DB_PASSWORD
```

1. Note the double `spec:` nesting — the outer `spec` is the rawResources wrapper

### After (native CRD)

```yaml
externalSecrets:
  secret:
    spec: # (1)!
      refreshInterval: 1h
      secretStoreRef:
        kind: ClusterSecretStore
        name: onepassword
      target:
        name: "{{ .Release.Name }}-secret"
        creationPolicy: Owner
      data:
        - secretKey: DB_PASSWORD
          remoteRef:
            key: my-app/DB_PASSWORD
```

1. Single flat `spec:` — no wrapping needed

!!! warning

    Native CRD keys do **not** support `helm.sh/hook` annotations. If your resource uses ArgoCD hooks (e.g. `argocd.argoproj.io/hook: PreSync`), keep it as `rawResources`.
