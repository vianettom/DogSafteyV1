defmodule DogFoodSafetyWeb.SearchLiveTest do
  use DogFoodSafetyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias DogFoodSafety.FoodDatabase

  test "renders the landing page with database counts", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/")

    assert html =~ "Is it safe for my dog?"
    assert html =~ to_string(FoodDatabase.count_total())
    assert html =~ to_string(FoodDatabase.count_safe())
    assert html =~ to_string(FoodDatabase.count_toxic())
  end

  test "shows no results before a search is entered", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/")
    refute html =~ "Search Results"
  end

  test "searching surfaces a matching item", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html =
      live
      |> form("form", search: %{query: "chocolate"})
      |> render_change()

    assert html =~ "Search Results"
    assert html =~ "chocolate"
    assert html =~ "theobromine"
  end

  test "searching by alias surfaces the parent item", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html =
      live
      |> form("form", search: %{query: "raisin"})
      |> render_change()

    assert html =~ "grapes"
  end

  test "a query with no matches reports nothing found", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html =
      live
      |> form("form", search: %{query: "zzzznotarealfood"})
      |> render_change()

    refute html =~ "Search Results"
  end

  test "browse safe items lists every safe item, not just foods", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html = live |> element("button", "Browse Safe Items") |> render_click()

    assert html =~ "Search Results (#{FoodDatabase.count_safe()} found)"
  end

  test "view toxic items lists every unsafe item", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html = live |> element("button", "View Toxic Items") |> render_click()

    assert html =~ "Search Results (#{FoodDatabase.count_toxic()} found)"
  end

  test "clearing the search resets the results", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    live
    |> form("form", search: %{query: "chocolate"})
    |> render_change()

    html = live |> element("button", "Clear Search") |> render_click()

    refute html =~ "Search Results"
  end

  test "the category filter offers every category present in the data", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/")

    assert html =~ ~s(name="search[category]")
    assert html =~ ~s(value="all")

    # Derived from the data, so adding a category to food_data.json without
    # adding it to SearchLive fails here rather than silently hiding items.
    data_categories = FoodDatabase.all() |> Enum.map(& &1.category) |> Enum.uniq()

    for category <- data_categories do
      assert html =~ ~s(value="#{category}"),
             "category #{inspect(category)} exists in the data but is missing from the filter"
    end
  end

  test "selecting a category with no query lists that category", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html =
      live
      |> form("form", search: %{query: "", category: "medication"})
      |> render_change()

    expected = length(FoodDatabase.list_by_category("medication"))
    assert html =~ "Search Results (#{expected} found)"
  end

  test "a category filter narrows a text search", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html =
      live
      |> form("form", search: %{query: "a", category: "plant"})
      |> render_change()

    expected = length(FoodDatabase.search("a", "plant"))
    assert html =~ "Search Results (#{expected} found)"
  end

  test "non-food categories are labelled correctly, not as plants", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    for {category, label} <- [
          {"household", "🧴 Household"},
          {"medication", "💊 Medication"},
          {"beverage", "🥤 Beverage"}
        ] do
      badges =
        live
        |> form("form", search: %{query: "", category: category})
        |> render_change()
        |> result_category_badges()

      assert badges != [], "no results rendered for category #{category}"

      assert Enum.uniq(badges) == [label],
             "#{category} items rendered as #{inspect(Enum.uniq(badges))}, expected #{label}"
    end
  end

  # The category badge on each result card. Scoped to the results so the
  # always-present category dropdown does not count as a match, and excluding
  # symptom badges, which carry an extra "badge-error" class.
  defp result_category_badges(html) do
    html
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(".card-body .badge.badge-outline:not(.badge-error)")
    |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))
  end

  test "safety icons resolve to real heroicon classes", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    html = live |> element("button", "View Toxic Items") |> render_click()

    # Blank if the hero-* Tailwind plugin or the class names ever drift.
    assert html =~ "hero-x-circle" or html =~ "hero-exclamation-triangle"
  end

  test "the emergency contact and disclaimer are always present", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/")

    assert html =~ "ASPCA Poison Control"
    assert html =~ "888"
    assert html =~ "Pet Poison Helpline"
    assert html =~ "Important Disclaimer"
  end
end
