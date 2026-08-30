#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

export MIX_ENV=prod

mix local.hex --force
mix local.rebar --force

mix deps.get --only prod
mix compile

# Asset toolchain: npm packages (daisyUI, topbar) must be installed before
# tailwind/esbuild run, otherwise the CSS/JS build resolves nothing.
npm ci --prefix assets

mix assets.setup
mix assets.deploy

mix release --overwrite
