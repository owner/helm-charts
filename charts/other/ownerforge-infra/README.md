# Owner Forge Infrastructure

`ownerforge-infra` provisions namespace-local PostgreSQL instances for Owner Forge and Temporal, plus a Temporal frontend and UI.

Install directly from a sibling checkout:

```sh
helm upgrade --install ownerforge-infra \
  ~/helm-charts/charts/other/ownerforge-infra \
  --namespace "$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')" \
  --wait --timeout 8m
```

The chart creates these Services:

- `<release>-forge-postgres:5432`
- `<release>-temporal:7233`
- `<release>-temporal-ui:8080`

Owner Forge can connect directly over cluster DNS with `DB_HOST=<release>-forge-postgres` and `TEMPORAL_HOST=<release>-temporal:7233`. Values use development-only database credentials until workspace secret injection is available.
