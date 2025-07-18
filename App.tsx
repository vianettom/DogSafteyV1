
import { foodDatabase, FoodItem } from "./data/foodDatabase";

function App() {
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [searchResults, setSearchResults] = useState<FoodItem[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<"all" | "food" | "plant">("all");

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim() === "") {
      setSearchResults([]);
      return;
    }

    const results = foodDatabase.filter((item) => {
      const matchesSearch =
        item.name.toLowerCase().includes(query.toLowerCase()) ||
        item.aliases.some((alias) =>
          alias.toLowerCase().includes(query.toLowerCase())
        );

      const matchesCategory =
        selectedCategory === "all" ||
        item.category === selectedCategory;

      return matchesSearch && matchesCategory;
    });
    setSearchResults(results);
  };

  const getSafetyIcon = (safe: boolean, severity: string) => {
    if (safe) {
      return <CheckCircle className="w-6 h-6 text-green-500" />;
    } else if (severity === "high") {
      return <XCircle className="w-6 h-6 text-red-500" />;
    } else {
      return <AlertTriangle className="w-6 h-6 text-yellow-500" />;
    }
  };

  const getSafetyColor = (safe: boolean, severity: string) => {
    if (safe) return "alert-success";
    if (severity === "high") return "alert-error";
    return "alert-warning";
  };

  const filteredDatabase = useMemo(() => {
    if (selectedCategory === "all") return foodDatabase;
    return foodDatabase.filter(
      (item) => item.category === selectedCategory
    );
  }, [selectedCategory]);

  return (
    <div className="min-h-screen bg-base-200">
      {/* Header */}
      <div className="navbar bg-primary text-primary-content">
        <div className="flex-1 flex justify-center">
          <h1 className="text-xl">🐕 Dog Food Safety Checker</h1>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8">
        {/* Hero Section */}
        <div className="hero bg-base-100 rounded-box shadow-xl mb-8">
          <div className="hero-content text-center">
            <div className="max-w-md">
              <h1 className="text-5xl">🍎🐶</h1>
              <h2 className="text-3xl mb-4">Is it safe for my dog?</h2>
              <p className="mb-6">
                Search through our database of 100+ foods and plants to find out if they're safe for your furry friend. All information is sourced from reputable veterinary organizations and research.
              </p>
              <div className="stats stats-vertical lg:stats-horizontal shadow">
                <div className="stat">
                  <div className="stat-title">Total Entries</div>
                  <div className="stat-value text-primary">100+</div>
                  <div className="stat-desc">Foods & Plants</div>
                </div>
                <div className="stat">
                  <div className="stat-title">Safe Items</div>
                  <div className="stat-value text-success">
                    {foodDatabase.filter((item) => item.safe).length}
                  </div>
                  <div className="stat-desc">Verified Safe</div>
                </div>
                <div className="stat">
                  <div className="stat-title">Toxic Items</div>
                  <div className="stat-value text-error">
                    {foodDatabase.filter((item) => !item.safe).length}
                  </div>
                  <div className="stat-desc">Avoid These</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Search Section */}
        <div className="card bg-base-100 shadow-xl mb-8">
          <div className="card-body">
            <div className="form-control">
              <label className="label justify-center">
                <span className="label-text text-lg">
                  Search for food or plant
                </span>
              </label>
              <div className="flex justify-center">
                <div className="flex flex-col sm:flex-row gap-3 w-full max-w-4xl">
                  <div className="form-control">
                    <select
                      className="select select-bordered select-lg"
                      value={selectedCategory}
                      onChange={(e) => {
                        setSelectedCategory(e.target.value as "all" | "food" | "plant");
                        if (searchQuery) handleSearch(searchQuery);
                      }}
                    >
                      <option value="all">All Categories</option>
                      <option value="food">Foods Only</option>
                      <option value="plant">Plants Only</option>
                    </select>
                  </div>
                  <div className="input-group flex-1">
                    <input
                      type="text"
                      placeholder="e.g., chocolate, grapes, carrots, azaleas..."
                      className="input input-bordered input-lg flex-1 text-center sm:text-left"
                      value={searchQuery}
                      onChange={(e) => handleSearch(e.target.value)}
                    />
                    <button className="btn btn-primary btn-lg">
                      <Search className="w-5 h-5" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Results Section */}
        {searchResults.length > 0 && (
          <div className="space-y-4">
            <h3 className="text-2xl mb-4">
              Search Results ({searchResults.length} found)
            </h3>
            {searchResults.map((item) => (
              <div key={item.id} className="card bg-base-100 shadow-xl">
                <div className="card-body">
                  <div className="flex items-center gap-4 mb-4">
                    {getSafetyIcon(item.safe, item.severity)}
                    <div className="flex-1">
                      <h4 className="card-title capitalize">{item.name}</h4>
                      <div className="badge badge-outline">
                        {item.category === "food" ? "🍽️ Food" : "🌱 Plant"}
                      </div>
                    </div>
                  </div>

                  <div className={`alert ${getSafetyColor(item.safe, item.severity)} mb-4`}>
                    <div className="flex-1">
                      <h5 className="font-bold">
                        {item.safe ? "✅ Safe for Dogs" : "⚠️ Not Safe for Dogs"}
                        {!item.safe && (
                          <span className={`ml-2 badge ${
                            item.severity === "high"
                              ? "badge-error"
                              : item.severity === "medium"
                                ? "badge-warning"
                                : "badge-info"
                          }`}
                          >
                            {item.severity} risk
                          </span>
                        )}
                      </h5>
                      <p className="text-sm">{item.description}</p>
                    </div>
                  </div>

                  {item.aliases.length > 0 && (
                    <div className="mb-4">
                      <h6 className="font-semibold mb-2">Also known as:</h6>
                      <div className="flex flex-wrap gap-2">
                        {item.aliases.map((alias, index) => (
                          <span key={index} className="badge badge-ghost">{alias}</span>
                        ))}
                      </div>
                    </div>
                  )}

                  {!item.safe && item.symptoms.length > 0 && (
                    <div className="mb-4">
                      <h6 className="font-semibold mb-2">Potential Symptoms:</h6>
                      <div className="flex flex-wrap gap-2">
                        {item.symptoms.map((symptom, index) => (
                          <span key={index} className="badge badge-outline badge-error">{symptom}</span>
                        ))}
                      </div>
                    </div>
                  )}

                  <div className="mb-4">
                    <h6 className="font-semibold mb-2">Recommended Action:</h6>
                    <p className="text-sm">{item.action}</p>
                  </div>

                  <div className="collapse collapse-arrow bg-base-200">
                    <input type="checkbox" />
                    <div className="collapse-title font-medium">
                      View Sources & Citations ({item.citations.length})
                    </div>
                    <div className="collapse-content">
                      <ul className="list-disc list-inside space-y-1">
                        {item.citations.map((citation, index) => (
                          <li key={index} className="text-sm">{citation}</li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {searchQuery && searchResults.length === 0 && (
          <div className="alert alert-info">
            <div>
              <h3 className="font-bold">No results found</h3>
              <div className="text-sm">
                We don't have information about "{searchQuery}" in our database of {filteredDatabase.length} items. When in doubt, consult your veterinarian before giving any new food to your dog.
              </div>
            </div>
          </div>
        )}

        {!searchQuery && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div className="card bg-success text-success-content shadow-xl">
              <div className="card-body">
                <h3 className="card-title">✅ Safe Foods</h3>
                <p>Common safe foods include carrots, apples (without seeds), blueberries, cooked chicken, rice, and sweet potatoes.</p>
                <div className="card-actions justify-end">
                  <button className="btn btn-success-content" onClick={() => {
                      setSelectedCategory("food");
                      setSearchQuery("");
                      setSearchResults(foodDatabase.filter((item) => item.safe && item.category === "food"));
                    }}>
                    Browse Safe Foods
                  </button>
                </div>
              </div>
            </div>

            <div className="card bg-error text-error-content shadow-xl">
              <div className="card-body">
                <h3 className="card-title">⚠️ Toxic Items</h3>
                <p>Never give chocolate, grapes, onions, garlic, xylitol, or macadamia nuts to dogs. Many common plants are also toxic.</p>
                <div className="card-actions justify-end">
                  <button className="btn btn-error-content" onClick={() => {
                      setSelectedCategory("all");
                      setSearchQuery("");
                      setSearchResults(foodDatabase.filter((item) => !item.safe));
                    }}>
                    View Toxic Items
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Emergency Contact */}
        <div className="card bg
