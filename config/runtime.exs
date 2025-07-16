host = System.get_env("RENDER_EXTERNAL_HOSTNAME") || "localhost" # highlight-line
port = String.to_integer(System.get_env("PORT") || "4000")
