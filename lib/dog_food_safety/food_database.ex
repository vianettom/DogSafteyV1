defmodule DogFoodSafety.FoodDatabase do
  @moduledoc """
  Database of foods and plants with safety information for dogs.
  """

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

  @food_data [
    # TOXIC FOODS - HIGH SEVERITY
    %{
      id: 1,
      name: "chocolate",
      aliases: ["cocoa", "cacao", "dark chocolate", "milk chocolate", "white chocolate"],
      safe: false,
      severity: "high",
      category: "food",
      description: "Chocolate contains theobromine and caffeine, which are toxic to dogs. Dark chocolate is more dangerous than milk chocolate.",
      symptoms: ["vomiting", "diarrhea", "seizures", "hyperactivity", "increased heart rate", "tremors"],
      action: "Seek immediate veterinary attention",
      citations: [
        "ASPCA Animal Poison Control Center",
        "American Kennel Club (AKC)",
        "Pet Poison Helpline",
        "Veterinary Information Network (VIN)"
      ]
    },
    %{
      id: 2,
      name: "grapes",
      aliases: ["grape", "raisins", "raisin", "sultanas"],
      safe: false,
      severity: "high",
      category: "food",
      description: "Grapes and raisins can cause acute kidney failure in dogs. The toxic substance is unknown.",
      symptoms: ["vomiting", "diarrhea", "lethargy", "loss of appetite", "kidney failure", "decreased urination"],
      action: "Seek immediate veterinary attention",
      citations: [
        "ASPCA Animal Poison Control Center",
        "Veterinary Information Network (VIN)",
        "American Veterinary Medical Association (AVMA)",
        "Journal of Veterinary Emergency and Critical Care"
      ]
    },
    %{
      id: 3,
      name: "xylitol",
      aliases: ["artificial sweetener", "sugar substitute", "birch sugar"],
      safe: false,
      severity: "high",
      category: "food",
      description: "Xylitol causes rapid insulin release and severe hypoglycemia in dogs.",
      symptoms: ["vomiting", "loss of coordination", "lethargy", "collapse", "seizures", "liver failure"],
      action: "Seek immediate emergency veterinary care",
      citations: [
        "ASPCA Animal Poison Control Center",
        "Pet Poison Helpline",
        "FDA Center for Veterinary Medicine",
        "Veterinary Clinics of North America"
      ]
    },
    %{
      id: 4,
      name: "macadamia nuts",
      aliases: ["macadamia", "queensland nut"],
      safe: false,
      severity: "high",
      category: "food",
      description: "Macadamia nuts cause weakness, depression, vomiting, and hyperthermia in dogs.",
      symptoms: ["weakness", "depression", "vomiting", "hyperthermia", "tremors", "difficulty walking"],
      action: "Seek immediate veterinary attention",
      citations: [
        "ASPCA Animal Poison Control Center",
        "Australian Veterinary Journal",
        "Pet Poison Helpline",
        "Small Animal Toxicology"
      ]
    },
    %{
      id: 5,
      name: "onions",
      aliases: ["onion", "garlic", "leeks", "chives", "shallots"],
      safe: false,
      severity: "medium",
      category: "food",
      description: "Onions and related plants contain compounds that can damage red blood cells causing anemia.",
      symptoms: ["vomiting", "diarrhea", "weakness", "pale gums", "difficulty breathing", "red urine"],
      action: "Contact veterinarian",
      citations: [
        "ASPCA Animal Poison Control Center",
        "Merck Veterinary Manual",
        "Pet Poison Helpline",
        "Veterinary Record Journal"
      ]
    },
    # SAFE FOODS
    %{
      id: 16,
      name: "carrots",
      aliases: ["carrot"],
      safe: true,
      severity: "safe",
      category: "food",
      description: "Carrots are safe and healthy for dogs when given in moderation. They provide beta-carotene and fiber.",
      symptoms: [],
      action: "Safe to give as treats",
      citations: [
        "American Kennel Club (AKC)",
        "ASPCA",
        "PetMD",
        "Veterinary Nutrition Journal"
      ]
    },
    %{
      id: 17,
      name: "apples",
      aliases: ["apple"],
      safe: true,
      severity: "safe",
      category: "food",
      description: "Apples are safe for dogs but remove seeds and core first as they contain cyanide.",
      symptoms: [],
      action: "Safe in moderation, remove seeds and core",
      citations: [
        "American Kennel Club (AKC)",
        "ASPCA",
        "PetMD",
        "Veterinary Partner"
      ]
    },
    %{
      id: 18,
      name: "blueberries",
      aliases: ["blueberry"],
      safe: true,
      severity: "safe",
      category: "food",
      description: "Blueberries are safe and provide antioxidants for dogs.",
      symptoms: [],
      action: "Safe to give as treats",
      citations: [
        "American Kennel Club (AKC)",
        "PetMD",
        "ASPCA",
        "Journal of Animal Science"
      ]
    },
    # TOXIC PLANTS
    %{
      id: 31,
      name: "azaleas",
      aliases: ["azalea", "rhododendron"],
      safe: false,
      severity: "high",
      category: "plant",
      description: "Azaleas contain grayanotoxins that can cause serious cardiovascular and neurological symptoms.",
      symptoms: ["vomiting", "diarrhea", "weakness", "cardiac arrhythmias", "coma"],
      action: "Seek immediate veterinary attention",
      citations: [
        "ASPCA Animal Poison Control Center",
        "Pet Poison Helpline",
        "Veterinary Toxicology Database",
        "Journal of Veterinary Emergency Medicine"
      ]
    },
    %{
      id: 32,
      name: "lilies",
      aliases: ["lily", "easter lily", "tiger lily", "day lily"],
      safe: false,
      severity: "high",
      category: "plant",
      description: "Many lilies are extremely toxic to cats and can cause kidney failure. Less toxic to dogs but still dangerous.",
      symptoms: ["vomiting", "diarrhea", "kidney failure", "lethargy"],
      action: "Seek immediate veterinary attention",
      citations: [
        "ASPCA Animal Poison Control Center",
        "Pet Poison Helpline",
        "Veterinary Emergency Medicine",
        "Toxicon Journal"
      ]
    }
  ]

  def all do
    Enum.map(@food_data, &struct(__MODULE__, &1))
  end

  def search(query, category \\ "all") do
    query = String.downcase(query)
    
    all()
    |> filter_by_category(category)
    |> Enum.filter(fn item ->
      String.contains?(String.downcase(item.name), query) or
      Enum.any?(item.aliases, &String.contains?(String.downcase(&1), query))
    end)
  end

  def get_by_id(id) do
    Enum.find(all(), &(&1.id == id))
  end

  def count_safe do
    all() |> Enum.count(&(&1.safe))
  end

  def count_toxic do
    all() |> Enum.count(&(!&1.safe))
  end

  def count_total do
    length(@food_data)
  end

  defp filter_by_category(items, "all"), do: items
  defp filter_by_category(items, category) do
    Enum.filter(items, &(&1.category == category))
  end
end