#!/usr/bin/env bash
#MISE description="Run terraform-docs on root module and all examples/modules"
set -euo pipefail

terraform-docs . -c .tfdocs-config.yml

for dir in examples/*/; do
	[[ -d "$dir" ]] || continue
	terraform-docs "$dir" -c examples/.tfdocs-examples-config.yml
done

for dir in modules/*/; do
	[[ -d "$dir" ]] || continue
	terraform-docs "$dir" -c .tfdocs-config.yml
done
