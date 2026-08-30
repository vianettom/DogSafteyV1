import Config

# config/runtime.exs is executed for all environments, including releases.
# It is the place to read environment variables at boot time.

if System.get_env("PHX_SERVER") do
  config :dog_food_safety, DogFoodSafetyWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "dogsafteyv1.onrender.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Bind to all interfaces so the platform's router can reach the app.
      ip: {0, 0, 0, 0},
      port: port
    ],
    check_origin: ["https://#{host}", "//#{host}"],
    secret_key_base: secret_key_base,
    server: true
end
