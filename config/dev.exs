import Config

config :dog_food_safety,
  ecto_repos: [DogFoodSafety.Repo]

config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "RFGabg1OzmVyCv7v5UnHLokZ1+RHUSkrj2KJRF3J7Y7PYvkUJxZjul0JMEc4SSai",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]


config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/dog_food_safety_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

    # Configure your database
config :dog_food_safety, DogFoodSafety.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "dog_food_safety_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :dog_food_safety, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
