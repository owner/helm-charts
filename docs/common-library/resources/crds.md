# CRD Resources

The common library provides native support for several popular Custom Resource Definitions (CRDs). These dedicated top-level keys replace the need for `rawResources` when working with supported CRD types, offering a cleaner syntax with automatic `apiVersion`, `kind`, and metadata handling.

## Supported CRDs

### External Secrets Operator

| Key | Kind | apiVersion |
|-----|------|------------|
| `externalSecrets` | ExternalSecret | `external-secrets.io/v1` |

### cert-manager

| Key | Kind | apiVersion |
|-----|------|------------|
| `certificates` | Certificate | `cert-manager.io/v1` |
| `certificateIssuers` | Issuer | `cert-manager.io/v1` |
| `certificateClusterIssuers` | ClusterIssuer | `cert-manager.io/v1` |

### Istio

| Key | Kind | apiVersion |
|-----|------|------------|
| `istioVirtualServices` | VirtualService | `networking.istio.io/v1` |
| `istioGateways` | Gateway | `networking.istio.io/v1` |
| `istioAuthorizationPolicies` | AuthorizationPolicy | `security.istio.io/v1` |
| `istioDestinationRules` | DestinationRule | `networking.istio.io/v1` |
| `istioServiceEntries` | ServiceEntry | `networking.istio.io/v1` |
| `istioPeerAuthentications` | PeerAuthentication | `security.istio.io/v1` |
| `istioRequestAuthentications` | RequestAuthentication | `security.istio.io/v1` |
| `istioSidecars` | Sidecar | `networking.istio.io/v1` |

## Common Options

All native CRD resources support the following fields:

### enabled

Enables or disables the resource. Defaults to `true`.

### nameOverride

Override the name suffix that is used for this resource.

### annotations

Provide additional annotations which may be required. Helm templates can be used.

### labels

Provide additional labels which may be required. Helm templates can be used.

### spec

The Kubernetes resource spec. Helm templates can be used. This is provided **flat** — do not nest `spec` inside `spec` like `rawResources` requires.

## Naming

Native CRD resources follow the same [naming conventions](names.md) as all other chart resources. The resource identifier is appended to the release name only when there are multiple resources of the same type.

## When to Use rawResources Instead

Native CRD keys do **not** support `helm.sh/hook` annotations for ArgoCD sync hooks. If your resource requires hook annotations (e.g. `argocd.argoproj.io/hook: PreSync`), continue using `rawResources`.

For any CRD types not listed above, use `rawResources` as a fallback.
