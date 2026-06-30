include base.mk

# VERSION documents the upstream release line the `upstream/` submodule is pinned to.
# Informational only: the PaC build derives the binary version from git-version
# (`results.version`, semver from the nearest git tag), not from this.
VERSION ?= v1.42.3

# COMPONENT_NAME is used by shared CI tasks (cache keys, artifact paths).
COMPONENT_NAME ?= syft

.PHONY: print-version
print-version: ##@Development Print the current version
	@echo $(VERSION)

# Binary-only component: no values.yaml / release.yaml to stamp.
# Override the base.mk default (which edits those manifests) with a no-op.
# The shared prepare step `make apply-patches upgrade-go-dependencies update-component-version`
# runs this uniformly across the family without failing here.
.PHONY: update-component-version
update-component-version:
	@echo "update-component-version: no-op for binary-only component ($(NEW_COMPONENT_VERSION))"
