import Config

# Tell Ecto which repos to start
config :dog_food_safety,
  generators: [timestamp_type: :utc_datetime],
  ecto_repos: [DogFoodSafety.Repo]

# Phoenix Endpoint configuration
config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    view: DogFoodSafetyWeb.ErrorHTML,
    accepts: ~w(html json),
    layout: false
  ],                            # ← comma here!
  pubsub_server: DogFoodSafety.PubSub,
  live_view: [signing_salt: "secret_salt"]

# Gettext (i18n) settings
config :dog_food_safety, DogFoodSafetyWeb.Gettext,
  locales: ~w(en),
  default_locale: "en"

# Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# esbuild (JS bundling)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# tailwind (CSS bundling)
config :tailwind,
  version: "3.3.0",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment-specific settings
import_config "#{config_env()}.exs"
