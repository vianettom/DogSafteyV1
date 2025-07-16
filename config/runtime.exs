config :dog_food_safety, DogFoodSafetyWeb.Endpoint,
  http: [
    # Render will set PORT for you
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  url: [
    host: "dogsafteyv1.onrender.com",
    port: 443,
    scheme: "https"
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  check_origin: [
    "https://dogsafteyv1.onrender.com",
    "//dogsafteyv1.onrender.com"
  ]
