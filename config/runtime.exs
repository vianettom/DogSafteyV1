import Config

if config_env() == :prod do
  # fetch the PORT env var (Render sets this automatically, default 10000)
  port =
    System.get_env("PORT")
    |> case do
      nil -> 4000      # fallback if not set
      val -> String.to_integer(val)
    end

  config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
    # bind to all interfaces
    http: [
      ip: {0, 0, 0, 0},
      port: port
    ],
    # enable the server in releases/runtime
    server: true,
    # standard prod settings
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end

import Config

if config_env() == :prod do
  host = "dogsafteyv1.onrender.com"

  config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
    # Tell Phoenix how to build URLs (for links, signed tokens, etc.)
    url: [
      host: host,
      port: 443,
      scheme: "https"
    ],
    # Use the PORT Render gives you at runtime
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    # Explicitly allow LiveView/WebSocket connections from your domain
check_origin: [
  "https://dogsafteyv1.onrender.com",
  "//dogsafteyv1.onrender.com"
],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end
