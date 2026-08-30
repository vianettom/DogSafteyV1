import Config

# The endpoint is started but does not serve requests; ConnCase drives it directly.
config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "d3+9Yb1kqXwVpN7sLzR0aTgHhE2uMcJfW5oQ8ByDvA6nKtSrPxZlUiGeCmObF4Ij",
  server: false

# Print only warnings and errors during test.
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation.
config :phoenix, :plug_init_mode, :runtime
