defmodule DogFoodSafetyWeb.Gettext do
  @moduledoc """
  A gettext backend, used for translating user-facing strings.

  Modules pull the macros in with `use Gettext, backend: DogFoodSafetyWeb.Gettext`,
  which `DogFoodSafetyWeb.html_helpers/0` already does for every component and
  LiveView.
  """

  use Gettext.Backend, otp_app: :dog_food_safety
end
