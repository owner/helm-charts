# Syncing Owner Helm Charts with BJW-S-Labs

## Overview

The `owner/helm-charts` repository is a fork/mirror of the `bjw-s-labs/helm-charts` repository. The owner version should closely track the upstream bjw-s-labs version to benefit from bug fixes and improvements, while allowing for customizations specific to the owner organization.

## Repository Structure

- **Upstream (Source)**: `https://github.com/bjw-s-labs/helm-charts`
- **Fork (Owner)**: `https://github.com/owner/helm-charts`
- **Remote References**:
  - `upstream`: Points to `bjw-s-labs/helm-charts` (fetch-only)
  - `origin`: Points to `owner/helm-charts` (your working remote)

## Initial Setup

If you haven't already configured the upstream remote:

```bash
# Add upstream remote (if not already present)
git remote add upstream https://github.com/bjw-s-labs/helm-charts.git
git fetch upstream
```

## Syncing Strategy

### Option 1: Regular Merge (Recommended for Most Cases)

This approach brings in upstream changes while preserving owner customizations.

```bash
# Update upstream refs
git fetch upstream

# Create a sync branch
git checkout -b sync/upstream-main

# Merge upstream/main into your current branch
git merge upstream/main --no-edit

# Resolve conflicts if any
# (Owner-specific URLs and references should be preserved)

# Test the changes
# - Run linting: just lint
# - Run tests: just test
# - Validate charts can be built

# Push and create PR for review
git push origin sync/upstream-main
gh pr create --title "chore: Sync upstream bjw-s-labs changes" \
  --body "$(cat <<'EOF'
## Summary
Merge recent changes from upstream bjw-s-labs/helm-charts repository.

## Changes Included
- [List key changes from upstream]

## Testing
- [x] Linting passed
- [x] Tests passed
- [x] Charts build successfully

## Conflicts Resolved
If any conflicts were present, they have been resolved while preserving owner customizations.
EOF
)"

# After approval and merge, push to upstream
git checkout main
git pull origin main
git push
```

### Option 2: Rebase (Use When Owner Has Few Customizations)

This keeps the commit history cleaner but is riskier with customizations.

```bash
git fetch upstream
git checkout -b sync/upstream-rebase
git rebase upstream/main

# Resolve conflicts
# Test thoroughly
git push origin sync/upstream-rebase
```

## Conflict Resolution Guide

When merging upstream changes, you may encounter conflicts. Here's how to handle them:

### Organization References
**Upstream Format**: `https://bjw-s-labs.github.io/helm-charts`
**Owner Format**: `https://owner.github.io/helm-charts`

**Action**: Keep owner format in Chart.yaml and values.schema.json files
```yaml
# Keep this:
repository: https://owner.github.io/helm-charts

# Not this:
repository: https://bjw-s-labs.github.io/helm-charts
```

### Version Bumps
If upstream bumps a dependency version and owner has a different version in use:
- Merge upstream version first
- Create a follow-up PR if owner needs different version
- Document the reason in the PR description

### Changelog Entries
**Upstream Format**:
```yaml
annotations:
  artifacthub.io/changes: |-
    - kind: changed
      description: |-
        Update common library to v4.6.3
```

**Owner Strategy**:
- Keep upstream changelog entries as-is
- Add owner-specific entries for owner customizations
- Document org migration in entries if applicable

## Git Tag Management

When upstream releases a new version (e.g., `common-4.6.3`):

1. **Fetch the tag**:
   ```bash
   git fetch upstream refs/tags/common-4.6.3:refs/tags/upstream-common-4.6.3
   ```

2. **Create owner version of the tag** (if owner version is different):
   ```bash
   git tag -a common-4.6.3 -m "Release common library v4.6.3 (owner)" <commit-hash>
   git push origin common-4.6.3
   ```

3. **Update schema references** to point to owner releases:
   - `charts/library/common/values.schema.json`
   - Any schema files referencing the common library

## Common Sync Scenarios

### Scenario 1: Upstream Published a Bug Fix

```bash
# 1. Fetch upstream
git fetch upstream

# 2. Check what changed
git log --oneline upstream/main..main

# 3. Merge the bug fix
git checkout main
git merge upstream/main
git push origin main
```

### Scenario 2: Owner Made Customization, Upstream Has Changes

```bash
# 1. Create feature branch
git checkout -b feature/sync-upstream

# 2. Merge upstream (may have conflicts)
git merge upstream/main

# 3. Resolve conflicts - preserve owner customizations
# For each conflict, decide:
# - Keep owner version (org URLs, specific versions)
# - Take upstream version (bug fixes, features)
# - Combine both (add owner-specific entries to changelog)

# 4. Verify no conflicts remain
git status

# 5. Test thoroughly
git push origin feature/sync-upstream
gh pr create ...
```

### Scenario 3: New Release in Owner Needs Tag

```bash
# After merging changes to main
git checkout main
git pull

# Create annotated tag
git tag -a common-4.6.3 -m "Release common library v4.6.3"

# Push tag
git push origin common-4.6.3

# Update schema $id references if needed
# - charts/library/common/values.schema.json
# - charts/other/*/schemas/*.schema.json
```

## Testing Before Merge

Always test synced changes:

```bash
# Run full test suite
just test

# Run linting
just lint

# Build specific charts
helm package charts/library/common
helm package charts/other/app-template
helm package charts/other/multus

# Verify dependency resolution
helm dependency update charts/other/multus
helm dependency update charts/other/app-template
```

## Best Practices

1. **Sync Regularly**: Pull upstream changes monthly or quarterly
2. **Test Thoroughly**: Run full test suite after merge
3. **Document Customizations**: Mark owner-specific changes in comments
4. **Create SemVer Tags**: When creating releases, use semantic versioning
5. **Update Changelogs**: Note when syncing major upstream changes
6. **Preserve Git History**: Keep meaningful commit messages
7. **Review Before Merge**: Have someone review conflict resolutions
8. **Communicate Changes**: Update team about significant upstream changes

## Handling Organization Migration

If the org name changes again (e.g., `owner` → `new-org`):

1. Update all repository URLs:
   - `Chart.yaml` dependencies
   - `values.schema.json` references
   - GitHub Pages URLs

2. Create a dedicated PR for the migration:
   ```bash
   git checkout -b chore/org-migration-new-org

   # Update URLs
   sed -i 's|owner.github.io|new-org.github.io|g' charts/**/Chart.yaml
   sed -i 's|owner/helm-charts|new-org/helm-charts|g' charts/**/*.json

   # Create tags pointing to both old and new org releases
   git tag -a new-org-common-4.6.3 -m "Release for new-org"
   git push origin new-org-common-4.6.3
   ```

3. Merge to main and plan release

## Troubleshooting

### "upstream remote not found"
```bash
git remote add upstream https://github.com/bjw-s-labs/helm-charts.git
git fetch upstream
```

### "Tag already exists"
```bash
git tag -d common-4.6.3  # Delete local
git push origin :refs/tags/common-4.6.3  # Delete remote
git tag -a common-4.6.3 -m "Message"  # Recreate
git push origin common-4.6.3
```

### "Merge conflicts in many files"
```bash
# View all conflicts
git diff --name-only --diff-filter=U

# View specific conflict
git diff charts/library/common/Chart.yaml

# Keep theirs (upstream)
git checkout --theirs charts/library/common/Chart.yaml

# Keep ours (owner)
git checkout --ours charts/library/common/Chart.yaml

# After resolving all
git add .
git commit -m "Resolve merge conflicts"
```

### "Schema resolution fails in CI"
Ensure git tags are created and pushed:
```bash
git tag -l  # List local tags
git ls-remote origin 'refs/tags/*'  # List remote tags

# If tag missing from remote:
git push origin common-4.6.3
```

## References

- [Forking Repositories](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [Syncing a Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork)
- [Helm Dependencies](https://helm.sh/docs/helm/helm_dependency/)
- [Git Tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
