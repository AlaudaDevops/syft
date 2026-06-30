# syft (Alauda overlay)

Alauda managed-fork overlay of [anchore/syft](https://github.com/anchore/syft) — a CLI tool and Go library for generating a Software Bill of Materials (SBOM).

## What this repo is

| | |
|---|---|
| **Component** | `syft` |
| **Upstream** | `https://github.com/anchore/syft` @ `v1.42.3` |
| **Our branch** | `release-1.42` (this branch) |
| **Deliverable** | `syft` binary tarball (linux/amd64 + linux/arm64) |
| **Nexus feed** | `{{ artifacts_url }}/repository/alauda-pipelines-catalog-binaries` |

## Layout

```
upstream/              ← git submodule (pristine anchore/syft@v1.42.3)
base.mk                ← shared Makefile infrastructure (canonical; never hand-edit)
Makefile               ← component overrides (VERSION, COMPONENT_NAME, update-component-version no-op)
.tekton/
  build.yaml           ← PaC PipelineRun (cross-compile binary, no image)
  patches/
    .placeholder
    0001-upgrade-go-dependencies.sh      ← base.mk entry point (Go version bump + dep upgrades)
    0002-fix-search-result-format.patch  ← fix %q→%d for integer fields in SearchResult.String()
    dependabot-go-get-commands.sh       ← go get commands for security/compat dependency bumps
```

## Development workflow

```bash
# Apply Alauda patches onto the pristine upstream submodule:
make apply-patches

# Run the same dependency upgrades the CI does:
make upgrade-go-dependencies update-component-version

# Build locally (verify the entrypoint + version stamping):
cd upstream
CGO_ENABLED=0 go build -trimpath \
  -ldflags="-w -s -X github.com/anchore/syft/cmd/syft.version=v1.42.4-alauda.0-localtest" \
  -o /tmp/syft ./cmd/syft
/tmp/syft version

# Lint (needs golangci-lint v2):
golangci-lint run --timeout=30m -v

# Revert upstream/ to pristine state:
make clean-patches
```

## Maintenance skills

| Task | Skill |
|------|-------|
| Sync to a newer upstream release | `/devops-upstream-upgrade` |
| Fix Go dependency CVEs | `/devops-fix-go-vulns` |
| Backport upstream source CVE fix | `/devops-upstream-backport-cve` |
| Add a new Alauda behavior patch | `make save-new-patch` then rename in `.tekton/patches/` |

## PaC pipeline

The `.tekton/build.yaml` PipelineRun fires on:
- Push to `main` or `release-*` branches
- Tag push

The pipeline cross-compiles `syft` for `linux/amd64` and `linux/arm64`, packages
each into a tarball, then uploads to the `-binaries` nexus feed (version-tagged).
