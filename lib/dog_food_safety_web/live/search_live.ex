defmodule DogFoodSafetyWeb.SearchLive do
  use DogFoodSafetyWeb, :live_view

  alias DogFoodSafety.FoodDatabase

  # Every category present in priv/data/food_data.json, plus the "all" pseudo
  # category. SearchLiveTest derives the expected set from the data, so adding a
  # category to the JSON without adding it here fails the suite.
  @categories [
    {"all", "All categories"},
    {"food", "🍽️ Food"},
    {"plant", "🌱 Plant"},
    {"household", "🧴 Household"},
    {"medication", "💊 Medication"},
    {"beverage", "🥤 Beverage"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:selected_category, "all")
     |> assign(:categories, @categories)
     |> assign(:total_count, FoodDatabase.count_total())
     |> assign(:safe_count, FoodDatabase.count_safe())
     |> assign(:toxic_count, FoodDatabase.count_toxic())}
  end

  @impl true
  def handle_event("search", %{"search" => search_params}, socket) do
    query = search_params["query"] || ""
    category = search_params["category"] || "all"

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:selected_category, category)
     |> assign(:search_results, results_for(query, category))}
  end

  @impl true
  def handle_event("browse_safe_items", _params, socket) do
    {:noreply, browse(socket, Enum.filter(FoodDatabase.all(), & &1.safe))}
  end

  @impl true
  def handle_event("browse_toxic_items", _params, socket) do
    {:noreply, browse(socket, Enum.reject(FoodDatabase.all(), & &1.safe))}
  end

  @impl true
  def handle_event("clear_search", _params, socket) do
    {:noreply, browse(socket, [])}
  end

  defp browse(socket, results) do
    socket
    |> assign(:search_query, "")
    |> assign(:selected_category, "all")
    |> assign(:search_results, results)
  end

  # An empty query with no category filter is the landing state, not a request
  # to dump the whole database. Choosing a category alone does list it.
  defp results_for(query, category) do
    cond do
      String.trim(query) != "" -> FoodDatabase.search(query, category)
      category != "all" -> FoodDatabase.list_by_category(category)
      true -> []
    end
  end

  # Full class names are written out literally so Tailwind's content scanner
  # finds them in this file. Interpolating the suffix would emit no CSS.
  defp get_safety_icon(true, _severity), do: "hero-check-circle"
  defp get_safety_icon(false, "high"), do: "hero-x-circle"
  defp get_safety_icon(false, _severity), do: "hero-exclamation-triangle"

  defp get_safety_color(true, _severity), do: "alert-success"
  defp get_safety_color(false, "high"), do: "alert-error"
  defp get_safety_color(false, _severity), do: "alert-warning"

  defp get_icon_color(true, _severity), do: "text-green-500"
  defp get_icon_color(false, "high"), do: "text-red-500"
  defp get_icon_color(false, _severity), do: "text-yellow-500"

  defp get_severity_badge("high"), do: "badge-error"
  defp get_severity_badge("medium"), do: "badge-warning"
  defp get_severity_badge(_), do: "badge-info"

  # Every category in the data gets its own label. Falls back to the raw name so
  # a newly added category shows up as itself rather than silently as "Plant".
  defp category_label(category) do
    case List.keyfind(@categories, category, 0) do
      {^category, label} -> label
      nil -> String.capitalize(category)
    end
  end
end
