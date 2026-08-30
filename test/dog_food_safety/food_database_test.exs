defmodule DogFoodSafety.FoodDatabaseTest do
  use ExUnit.Case, async: true

  alias DogFoodSafety.FoodDatabase

  describe "all/0" do
    test "returns every item as a struct" do
      items = FoodDatabase.all()

      assert length(items) == FoodDatabase.count_total()
      assert Enum.all?(items, &is_struct(&1, FoodDatabase))
    end

    test "populates every struct field" do
      for item <- FoodDatabase.all() do
        assert is_integer(item.id)
        assert is_binary(item.name)
        assert is_list(item.aliases)
        assert is_boolean(item.safe)
        assert is_binary(item.severity)
        assert is_binary(item.category)
        assert is_binary(item.description)
        assert is_list(item.symptoms)
        assert is_binary(item.action)
        assert is_list(item.citations)
      end
    end
  end

  describe "search/2" do
    test "finds an item by exact name" do
      names = FoodDatabase.search("chocolate") |> Enum.map(& &1.name)
      assert "chocolate" in names
    end

    test "is case insensitive" do
      assert FoodDatabase.search("CHOCOLATE") == FoodDatabase.search("chocolate")
      assert FoodDatabase.search("ChOcOlAtE") == FoodDatabase.search("chocolate")
    end

    test "matches on a partial name" do
      names = FoodDatabase.search("choc") |> Enum.map(& &1.name)
      assert "chocolate" in names
    end

    test "matches on an alias" do
      names = FoodDatabase.search("raisin") |> Enum.map(& &1.name)
      assert "grapes" in names
    end

    test "returns an empty list when nothing matches" do
      assert FoodDatabase.search("zzzznotarealfood") == []
    end

    test "filters by category" do
      results = FoodDatabase.search("a", "plant")

      assert results != []
      assert Enum.all?(results, &(&1.category == "plant"))
    end

    test "defaults to searching every category" do
      categories = FoodDatabase.search("a") |> Enum.map(& &1.category) |> Enum.uniq()
      assert length(categories) > 1
    end

    test "an unknown category matches nothing" do
      assert FoodDatabase.search("chocolate", "nonsense") == []
    end
  end

  describe "list_by_category/1" do
    test "\"all\" returns everything" do
      assert length(FoodDatabase.list_by_category("all")) == FoodDatabase.count_total()
    end

    test "returns only items in the given category" do
      for category <- ~w(food plant household medication beverage) do
        results = FoodDatabase.list_by_category(category)

        assert results != [], "no items in category #{category}"
        assert Enum.all?(results, &(&1.category == category))
      end
    end

    test "every item is reachable through some category" do
      reachable =
        ~w(food plant household medication beverage)
        |> Enum.flat_map(&FoodDatabase.list_by_category/1)
        |> Enum.map(& &1.id)
        |> MapSet.new()

      all = FoodDatabase.all() |> Enum.map(& &1.id) |> MapSet.new()

      assert MapSet.equal?(reachable, all)
    end
  end

  describe "get_by_id/1" do
    test "returns the matching item" do
      %{id: id, name: name} = FoodDatabase.all() |> hd()
      assert %{name: ^name} = FoodDatabase.get_by_id(id)
    end

    test "returns nil for an unknown id" do
      assert FoodDatabase.get_by_id(-1) == nil
    end
  end

  describe "counts" do
    test "safe and toxic counts partition the database" do
      assert FoodDatabase.count_safe() + FoodDatabase.count_toxic() ==
               FoodDatabase.count_total()
    end

    test "counts are positive" do
      assert FoodDatabase.count_safe() > 0
      assert FoodDatabase.count_toxic() > 0
    end
  end
end
