defmodule DogFoodSafety.FoodDataTest do
  @moduledoc """
  Schema and integrity checks against priv/data/food_data.json itself.

  These read the raw JSON with string keys rather than going through
  `FoodDatabase`, so that schema drift is caught at the source of truth —
  `struct/2` silently discards unknown keys, which would otherwise hide typos.
  """

  use ExUnit.Case, async: true

  @required_fields ~w(id name aliases safe severity category description symptoms action citations)
  @valid_severities ~w(low medium high)
  @valid_categories ~w(food plant household medication beverage)

  setup_all do
    path = Path.join(:code.priv_dir(:dog_food_safety), "data/food_data.json")
    {:ok, items: path |> File.read!() |> Jason.decode!()}
  end

  test "is a non-empty list of objects", %{items: items} do
    assert is_list(items)
    assert length(items) > 0
    assert Enum.all?(items, &is_map/1)
  end

  test "every item has exactly the expected fields and no extras", %{items: items} do
    for item <- items do
      actual = item |> Map.keys() |> Enum.sort()

      assert actual == Enum.sort(@required_fields),
             "item #{inspect(item["name"] || item["id"])} has fields #{inspect(actual)}"
    end
  end

  test "ids are unique positive integers", %{items: items} do
    ids = Enum.map(items, & &1["id"])

    for id <- ids do
      assert is_integer(id) and id > 0, "bad id: #{inspect(id)}"
    end

    assert length(Enum.uniq(ids)) == length(ids), "duplicate ids: #{inspect(duplicates(ids))}"
  end

  test "names are unique and non-empty", %{items: items} do
    names = Enum.map(items, & &1["name"])

    for name <- names do
      assert is_binary(name) and String.trim(name) != "", "bad name: #{inspect(name)}"
      assert name == String.trim(name), "name has surrounding whitespace: #{inspect(name)}"
    end

    assert length(Enum.uniq(names)) == length(names),
           "duplicate names: #{inspect(duplicates(names))}"
  end

  test "names are unique case-insensitively", %{items: items} do
    # Search downcases both sides, so two names differing only in case would be
    # indistinguishable to a user.
    folded = Enum.map(items, &String.downcase(&1["name"]))

    assert length(Enum.uniq(folded)) == length(folded),
           "names collide when downcased: #{inspect(duplicates(folded))}"
  end

  test "safe is a boolean", %{items: items} do
    for item <- items do
      assert is_boolean(item["safe"]), "#{item["name"]}: safe is #{inspect(item["safe"])}"
    end
  end

  test "severity is one of #{inspect(@valid_severities)}", %{items: items} do
    for item <- items do
      assert item["severity"] in @valid_severities,
             "#{item["name"]}: severity #{inspect(item["severity"])}"
    end
  end

  test "category is one of #{inspect(@valid_categories)}", %{items: items} do
    for item <- items do
      assert item["category"] in @valid_categories,
             "#{item["name"]}: category #{inspect(item["category"])}"
    end
  end

  test "description and action are non-empty strings", %{items: items} do
    for item <- items, field <- ~w(description action) do
      value = item[field]

      assert is_binary(value) and String.trim(value) != "",
             "#{item["name"]}: #{field} is #{inspect(value)}"
    end
  end

  test "aliases, symptoms and citations are lists of non-empty strings", %{items: items} do
    for item <- items, field <- ~w(aliases symptoms citations) do
      value = item[field]
      assert is_list(value), "#{item["name"]}: #{field} is #{inspect(value)}"

      for entry <- value do
        assert is_binary(entry) and String.trim(entry) != "",
               "#{item["name"]}: #{field} contains #{inspect(entry)}"
      end
    end
  end

  test "every item carries at least one citation", %{items: items} do
    uncited = for item <- items, item["citations"] == [], do: item["name"]
    assert uncited == [], "items with no citation: #{inspect(uncited)}"
  end

  # Known pre-existing alias/name collisions, pending the content review.
  # Each one makes a single search return two entries that may disagree, so this
  # list should only ever shrink. Do not add to it.
  #
  #   {item name, offending alias}
  @known_alias_collisions [
    # Safety-relevant: searching "peanut butter" returns both the unsafe
    # xylitol entry and the safe peanut butter entry.
    {"xylitol", "peanut butter"},
    # Duplicate records that should be merged into the entry they shadow.
    {"oleander (variant)", "oleander"},
    {"sago palm (variant)", "sago palm"},
    # Narrower entries that legitimately exist in their own right; the alias is
    # redundant rather than contradictory.
    {"potato", "sweet potato"},
    {"chocolate", "dark chocolate"},
    {"chocolate", "milk chocolate"},
    {"bread", "white bread"},
    {"onions", "chives"}
  ]

  test "no new aliases collide with another item's name", %{items: items} do
    names = MapSet.new(items, & &1["name"])

    collisions =
      for item <- items,
          alias_name <- item["aliases"],
          MapSet.member?(names, alias_name),
          do: {item["name"], alias_name}

    assert collisions -- @known_alias_collisions == [],
           "new alias/name collisions: #{inspect(collisions -- @known_alias_collisions)}"

    # Keeps the allowlist honest as entries get fixed.
    assert @known_alias_collisions -- collisions == [],
           "these collisions are fixed — remove them from @known_alias_collisions: " <>
             inspect(@known_alias_collisions -- collisions)
  end

  test "unsafe items give an actionable instruction", %{items: items} do
    for item <- items, item["safe"] == false do
      assert String.trim(item["action"]) != "",
             "#{item["name"]} is unsafe but has no action"
    end
  end

  defp duplicates(list) do
    list
    |> Enum.frequencies()
    |> Enum.filter(fn {_value, count} -> count > 1 end)
    |> Enum.map(&elem(&1, 0))
  end
end
