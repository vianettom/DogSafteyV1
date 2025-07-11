defmodule DogFoodSafetyWeb.SearchLive do
  use DogFoodSafetyWeb, :live_view

  alias DogFoodSafety.FoodDatabase

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:selected_category, "all")
     |> assign(:total_count, FoodDatabase.count_total())
     |> assign(:safe_count, FoodDatabase.count_safe())
     |> assign(:toxic_count, FoodDatabase.count_toxic())}
  end

  @impl true
  def handle_event("search", %{"search" => search_params}, socket) do
    query = search_params["query"] || ""
    category = search_params["category"] || "all"
    
    results = if String.trim(query) == "" do
      []
    else
      FoodDatabase.search(query, category)
    end

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:search_results, results)
     |> assign(:selected_category, category)}
  end

  @impl true
  def handle_event("browse_safe_foods", _params, socket) do
    results = FoodDatabase.search("", "food") 
              |> Enum.filter(&(&1.safe))

    {:noreply,
     socket
     |> assign(:search_query, "")
     |> assign(:search_results, results)
     |> assign(:selected_category, "food")}
  end

  @impl true
  def handle_event("browse_toxic_items", _params, socket) do
    results = FoodDatabase.search("", "all")
              |> Enum.filter(&(!&1.safe))

    {:noreply,
     socket
     |> assign(:search_query, "")
     |> assign(:search_results, results)
     |> assign(:selected_category, "all")}
  end

  @impl true
  def handle_event("clear_search", _params, socket) do
    {:noreply,
     socket
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:selected_category, "all")}
  end

  defp get_safety_icon(true, _severity), do: "check-circle"
  defp get_safety_icon(false, "high"), do: "x-circle"
  defp get_safety_icon(false, _severity), do: "exclamation-triangle"

  defp get_safety_color(true, _severity), do: "alert-success"
  defp get_safety_color(false, "high"), do: "alert-error"
  defp get_safety_color(false, _severity), do: "alert-warning"

  defp get_icon_color(true, _severity), do: "text-green-500"
  defp get_icon_color(false, "high"), do: "text-red-500"
  defp get_icon_color(false, _severity), do: "text-yellow-500"

  defp get_severity_badge("high"), do: "badge-error"
  defp get_severity_badge("medium"), do: "badge-warning"
  defp get_severity_badge(_), do: "badge-info"
end