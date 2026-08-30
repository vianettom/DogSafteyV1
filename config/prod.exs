import Config

# Serve the digested, fingerprinted assets produced by `mix assets.deploy`.
# Without this, priv/static/cache_manifest.json is built and never used.
config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production.
config :logger, level: :info

# Runtime configuration (secrets, host, port) lives in config/runtime.exs.
