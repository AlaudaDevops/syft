#!/bin/sh
# Fixed entrypoint run by `make upgrade-go-dependencies` — base.mk loops over
# .tekton/patches/[0-9]*.sh and runs each with cwd = upstream/. Keep this file's
# logic generic; the actual per-CVE dependency bumps live in the sibling
# dependabot-go-get-commands.sh (which dependabot / /devops-fix-go-vulns maintain).
#
# Fail fast: a dropped security upgrade must BREAK the build, not ship silently as
# a still-vulnerable "green" tree.
set -e

echo "Upgrading go modules to fix vulnerabilities..."
go version

# Bump the module's Go toolchain directive to 1.26.4. The GO_BUILDER step image
# already provides Go 1.26 — keep this in sync with the build.yaml image tag.
go mod edit -go=1.26.4

# Apply dependabot's go-get upgrades (the actual CVE fixes), then tidy.
if [ "${SKIP_DEPENDABOT_COMMANDS:-false}" != "true" ]; then
    bash -ex "$(dirname "$0")/dependabot-go-get-commands.sh"
else
    echo "Skipping dependabot commands (SKIP_DEPENDABOT_COMMANDS=true)"
    time go mod tidy
    time go mod download -x
fi
