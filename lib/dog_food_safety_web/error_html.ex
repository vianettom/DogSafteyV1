defmodule DogFoodSafetyWeb.ErrorHTML do
  use DogFoodSafetyWeb, :html

  def render("404.html", assigns) do
    ~H"""
    <section class="text-center p-8">
      <h1 class="text-4xl font-bold">404: Page not found</h1>
      <p>The page you were looking for doesn’t exist.</p>
    </section>
    """
  end

  def render("500.html", assigns) do
    ~H"""
    <section class="text-center p-8">
      <h1 class="text-4xl font-bold">500: Internal Server Error</h1>
      <p>Something went wrong on our end.</p>
    </section>
    """
  end
end
