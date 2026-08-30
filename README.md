# Dog Food Safety

A search tool for checking whether something is safe for a dog to eat.

Enter a food, plant, household product, medication, or beverage and the app reports
whether it is safe or toxic, along with severity, symptoms, a recommended action, and
the sources the entry was drawn from.

> **This is not veterinary advice.** It is a reference aid. If your dog has eaten
> something toxic, call a vet or one of the emergency lines shown in the app.

## Stack

- **Elixir / OTP 28**, [Phoenix](https://www.phoenixframework.org/) 1.8 with LiveView 1.2, served by [Bandit](https://github.com/mtrudel/bandit)
- **Tailwind CSS 3** + [daisyUI](https://daisyui.com) 4 for styling, [Heroicons](https://heroicons.com) for icons
- No database. The dataset is a static JSON file read at compile time.

## Requirements

- Elixir 1.15+ (developed on 1.19) and Erlang/OTP 26+ (developed on 28)
- Node.js 20+ (only to install the CSS/JS packages; the Tailwind and esbuild
  binaries themselves are fetched by Mix)

## Getting started

```bash
mix setup        # fetch deps, install the asset toolchain, build assets
mix phx.server   # http://localhost:4000
```

`mix setup` runs `npm install --prefix assets` for you. If you ever build the assets
directly, make sure the npm packages are installed first — daisyUI and topbar are
resolved from `assets/node_modules`, and Tailwind silently produces unstyled CSS
without them.

## Tests

```bash
mix test
```

The suite covers three things:

| File | What it checks |
| --- | --- |
| `test/dog_food_safety/food_data_test.exs` | The dataset itself: schema, required fields, unique ids and names, valid categories and severities, and that every entry carries a citation |
| `test/dog_food_safety/food_database_test.exs` | Search, alias matching, category filtering, and the counts |
| `test/dog_food_safety_web/live/search_live_test.exs` | The LiveView: rendering, searching, filtering, and labelling |

## The dataset

`priv/data/food_data.json` is the single source of truth. It is a flat JSON array,
loaded and decoded at compile time by `DogFoodSafety.FoodDatabase`, so **any edit
requires a recompile** to take effect.

Each entry looks like this:

```json
{
  "id": 1,
  "name": "chocolate",
  "aliases": ["cocoa", "cacao", "dark chocolate"],
  "safe": false,
  "severity": "high",
  "category": "food",
  "description": "Chocolate contains theobromine and caffeine, which are toxic to dogs.",
  "symptoms": ["vomiting", "diarrhea", "seizures"],
  "action": "Contact vet immediately.",
  "citations": ["ASPCA Animal Poison Control Center: https://... (accessed July 2025)"]
}
```

- `safe` — boolean
- `severity` — `low` | `medium` | `high`
- `category` — `food` | `plant` | `household` | `medication` | `beverage`
- `citations` — must be non-empty; every claim needs a source

Adding a new category also means adding it to `@categories` in
`DogFoodSafetyWeb.SearchLive`, or the items become unreachable from the filter. The
test suite fails if you forget.

### Known data issues

`food_data_test.exs` carries a `@known_alias_collisions` allowlist of entries where an
alias is also another item's name, which makes one search return two entries that can
disagree. Two are safety-relevant and worth fixing first:

- `xylitol` lists `peanut butter` as an alias, while `peanut butter` is its own entry marked safe
- `potato` lists `sweet potato` as an alias, while `sweet potato` is its own entry marked safe

The allowlist is asserted in both directions, so it can only shrink.

Citations are also overdue for review — all 170 entries were last verified in July 2025.

## Deployment

`build.sh` performs a production build (deps, compile, npm install, digested assets,
release). Required environment variables:

| Variable | Required | Notes |
| --- | --- | --- |
| `SECRET_KEY_BASE` | yes | Generate with `mix phx.gen.secret` |
| `PORT` | no | Defaults to `4000`; hosts usually set this |
| `PHX_HOST` | no | Public hostname, used for URLs and websocket origin checks |

## Project layout

```
assets/                 CSS/JS sources, Tailwind config, npm manifest
config/                 config.exs + per-env; runtime.exs holds prod secrets
lib/dog_food_safety/    FoodDatabase (search, filtering, counts)
lib/dog_food_safety_web/ Endpoint, router, SearchLive, components
priv/data/              food_data.json — the dataset
test/                   ExUnit suite
```
