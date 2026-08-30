defmodule DogFoodSafety.FoodDatabase do
  @moduledoc """
  Loads foods & plants from priv/data/food_data.json and exposes search functions and counts.
  """

  # Define the data struct
  defstruct [
    :id,
    :name,
    :aliases,
    :safe,
    :severity,
    :category,
    :description,
    :symptoms,
    :action,
    :citations
  ]

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          aliases: [String.t()],
          safe: boolean(),
          severity: String.t(),
          category: String.t(),
          description: String.t(),
          symptoms: [String.t()],
          action: String.t(),
          citations: [String.t()]
        }

  # Path to the JSON data file in priv/
  @json_path Path.join(:code.priv_dir(:dog_food_safety), "data/food_data.json")

  # Load and decode JSON at compile time (using atom keys)
  @raw_data @json_path
            |> File.read!()
            |> Jason.decode!(keys: :atoms)

  @doc "Returns all food & plant items as structs"
  @spec all() :: [t()]
  def all do
    Enum.map(@raw_data, &struct(__MODULE__, &1))
  end

  @doc "Search items by query and optional category (all | food | plant)"
  @spec search(String.t(), String.t()) :: [t()]
  def search(query, category \\ "all") do
    q = String.downcase(query)

    all()
    |> filter_by_category(category)
    |> Enum.filter(fn item ->
      String.contains?(String.downcase(item.name), q) or
        Enum.any?(item.aliases, fn alias -> String.contains?(String.downcase(alias), q) end)
    end)
  end

  @doc """
  List every item in a category, with no text query.

  Prefer this over `search("", category)`, which only works because
  `String.contains?/2` returns true for an empty needle.
  """
  @spec list_by_category(String.t()) :: [t()]
  def list_by_category(category), do: all() |> filter_by_category(category)

  @doc "Get a single item by its ID"
  @spec get_by_id(integer()) :: t() | nil
  def get_by_id(id), do: Enum.find(all(), &(&1.id == id))

  @doc "Count how many items are marked safe"
  @spec count_safe() :: integer()
  def count_safe, do: all() |> Enum.count(& &1.safe)

  @doc "Count how many items are marked unsafe"
  @spec count_toxic() :: integer()
  def count_toxic, do: all() |> Enum.count(&(not &1.safe))

  @doc "Total number of items in the database"
  @spec count_total() :: integer()
  def count_total, do: length(@raw_data)

  # Private helper for filtering by category
  defp filter_by_category(items, "all"), do: items

  defp filter_by_category(items, category) do
    Enum.filter(items, &(&1.category == category))
  end
end
