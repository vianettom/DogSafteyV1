defmodule DogFoodSafety.Repo do
  use Ecto.Repo,
    otp_app: :dog_food_safety,
    adapter: Ecto.Adapters.Postgres
end
