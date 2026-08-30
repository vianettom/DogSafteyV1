# Handoff: dataset citation audit (`dogsafety`)

Self-contained brief for an agent picking up the remaining work on this project.
You do not need any prior conversation context. Read this file top to bottom before
touching anything.

---

## 1. What the project is

A Phoenix LiveView app that answers "can my dog eat this?". A user types a food, plant,
household product, medication, or beverage; the app returns whether it is safe or toxic,
with severity, symptoms, a recommended action, and citations.

**The output of this app is health guidance that people will act on when their pet may
be poisoned.** Accuracy matters more than throughput. When a source is ambiguous, say so
in the entry rather than picking the confident-sounding option.

- Repo root: `/Users/Tom/Downloads/dogsafety`, branch `master`
- Stack: Elixir/OTP 28, Phoenix 1.8, LiveView 1.2, Bandit, Tailwind 3 + daisyUI 4
- No database. The dataset is a single JSON file.

```bash
mix setup        # deps + asset toolchain
mix phx.server   # http://localhost:4000
mix test         # 44 tests, all currently passing
```

## 2. State of the codebase

Engineering modernization is **complete and verified**. Do not redo it:

1. `.gitignore` added; `deps/`, `_build/`, and built assets untracked (4,747 → ~40 tracked files)
2. Asset pipeline made reproducible — `assets/package.json` + committed lockfile
3. `config/runtime.exs` de-duplicated; `config/prod.exs` populated
4. Unused Ecto/Postgres stack removed
5. Test suite + GitHub Actions CI added
6. Category filter, labelling, and Heroicons fixed
7. Phoenix 1.7→1.8, LiveView 0.20→1.2, phoenix_html 3→4, gettext 0.26→1.0, Cowboy→Bandit

Everything is **staged but not committed**. Coordinate with the owner (Tom) before
committing or rebasing.

**Your task is item 8, and only item 8: the dataset.** No framework, config, or build
changes are needed. If you think one is, raise it rather than doing it.

## 3. The dataset

`priv/data/food_data.json` — a flat JSON array, 170 entries, ids 1–170, no gaps or duplicates.

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

| Field | Rule |
| --- | --- |
| `id` | unique positive integer |
| `name` | unique, non-empty, trimmed |
| `aliases` / `symptoms` / `citations` | lists of non-empty strings |
| `safe` | boolean |
| `severity` | `low` \| `medium` \| `high` |
| `category` | `food` \| `plant` \| `household` \| `medication` \| `beverage` |

Current distribution: 129 food, 27 plant, 7 household, 5 medication, 2 beverage ·
83 safe / 87 unsafe · 94 low, 34 medium, 42 high.

> **Critical constraint:** `DogFoodSafety.FoodDatabase` reads and decodes this JSON at
> **compile time** (`@raw_data` via `File.read!` + `Jason.decode!`). Editing the JSON has
> no effect until you recompile. If a change seems not to apply, run `mix compile --force`.

## 4. The actual problem

The dataset is structurally clean — every entry has all ten fields, ids and names are
unique, and every `citations` array is non-empty. **That structural cleanliness is
misleading.** Treat the following as the real starting point:

| Finding | Count |
| --- | --- |
| Entries whose only citation is the literal string `"General veterinary advice (accessed July/August 2025)"` | **119 / 170 (70%)** |
| Entries with a real named source | 51 |
| Entries with any URL at all | **39** |
| Citations per entry | exactly 1, for all 170 |
| Citations dated "accessed July 2025" | 160 (10 are August 2025) |

"General veterinary advice" is a placeholder, not a citation. It names no source, no
organization, and no URL, and cannot be verified or re-checked by anyone.

The highest-risk subset: **36 entries are marked unsafe *and* have only the placeholder
citation. 9 of those are `severity: high`** — `batteries`, `cooked bones`,
`corn on the cob`, `fatty foods`, `marijuana`, `raw salmon`, `raw yeast dough`,
`star fruit`, `yeast`. These tell a worried owner their dog is in serious danger on no
recorded authority.

There is also a confirmed factual error, in an entry that *does* have a real ASPCA citation:

- **`grapes` (id 2)** — description reads *"The toxic substance is unknown."* Tartaric
  acid was identified as the likely toxic principle in 2021–2022 (Wegenast et al.,
  *J Vet Emerg Crit Care*, 2022), work published by the ASPCA's own poison control
  centre — the very source the entry cites. The citation is stale enough to contradict
  itself. Assume this is not the only such case; it was found by spot-check, not audit.

## 5. Suggested order of work

1. **The 9 high-severity unsafe entries with placeholder citations.** Highest harm if wrong.
2. **The remaining 27 unsafe entries with placeholder citations.**
3. **Re-verify the 51 real-cited entries**, starting with `grapes`. Confirm the URL still
   resolves, still supports the claim, and reflects current guidance.
4. **The 83 safe entries.** A wrong "safe" is as dangerous as a wrong "toxic" — this is
   where a false negative gets a dog poisoned.
5. **Resolve the known defects in §6.**

Work in reviewable batches (~10–20 entries), not one 170-entry rewrite. State clearly in
each batch what you verified versus what you could not.

## 6. Known specific defects

### Alias/name collisions

Eight aliases are also another entry's `name`, so one search returns two entries that may
disagree. Enumerated in `@known_alias_collisions` in
`test/dog_food_safety/food_data_test.exs`.

- **`xylitol` (id 3) lists `peanut butter` as an alias**, and `peanut butter` (id 23) is
  its own entry with `safe: true`. Searching "peanut butter" returns one unsafe and one
  safe result. This is the only pair with contradictory verdicts, and the only one that
  is safety-relevant. The intent was presumably "some peanut butter contains xylitol",
  which belongs in the description, not in the alias list.
- **`oleander (variant)` (id 169) and `sago palm (variant)`** — near-duplicate records
  shadowing `oleander` (id 42) and `sago palm` (id 40), with thinner descriptions and
  weaker citations. Almost certainly should be merged into the originals and deleted.
- `potato`/`sweet potato`, `chocolate`/`dark chocolate`, `chocolate`/`milk chocolate`,
  `bread`/`white bread`, `onions`/`chives` — redundant rather than contradictory. Both
  sides agree on `safe`. Lower priority; removing the redundant alias is usually enough.

### Cosmetic

- Names `NSAIDs` and `ZZ plant`, and the alias `SSRIs`, are not lowercase. Search
  downcases both sides so this is harmless; leave it unless you are touching the entry
  anyway. It is deliberately **not** enforced by a test.

## 7. Guardrails you must respect

`mix test` must stay green. The suite is the contract:

| File | Enforces |
| --- | --- |
| `test/dog_food_safety/food_data_test.exs` | Dataset schema, field presence, uniqueness, valid enums, non-empty citations |
| `test/dog_food_safety/food_database_test.exs` | Search, alias matching, category filtering, counts |
| `test/dog_food_safety_web/live/search_live_test.exs` | LiveView rendering, filtering, labelling |

Two mechanisms will fight you if you are careless — by design:

1. **`@known_alias_collisions` is asserted in both directions.** A new collision fails the
   suite, *and* fixing one without removing it from the list also fails. When you fix a
   collision, delete its tuple. The list may only shrink.
2. **The category filter is derived from the data.** Adding a new `category` value to the
   JSON without adding it to `@categories` in
   `lib/dog_food_safety_web/live/search_live.ex` fails the suite — otherwise those items
   become unreachable in the UI.

Also note: several tests assert against live counts (`count_safe/0`, `count_total/0`)
rather than hardcoded numbers, so changing verdicts will not spuriously break them. But
**deleting entries changes `count_total`**, which is user-visible on the landing page.

## 8. Sourcing standards

Acceptable primary sources:

- ASPCA Animal Poison Control Center — <https://www.aspca.org/pet-care/animal-poison-control>
- ASPCA Toxic and Non-Toxic Plants database (for `category: "plant"`)
- Pet Poison Helpline — <https://www.petpoisonhelpline.com/>
- Merck Veterinary Manual — <https://www.merckvetmanual.com/>
- Peer-reviewed veterinary literature (e.g. *J Vet Emerg Crit Care*), cited properly

Not acceptable: content farms, pet blogs, AI-generated listicles, retailer copy, and
anything that cannot be linked.

Required citation format — named source, URL, access date:

```
ASPCA Animal Poison Control Center: https://www.aspca.org/... (accessed <Month Year>)
```

Rules:

- **Every claim needs a source.** If you cannot find one, do not invent a citation and do
  not leave the placeholder. Flag the entry for human review and leave it unchanged.
- Update the access date **only** when you actually re-read the source.
- Multiple citations per entry are allowed and encouraged; the schema takes a list, and
  every entry currently has exactly one.
- If a source contradicts the entry's `safe` or `severity`, change the entry to match the
  source and call it out explicitly in your report.

## 9. Definition of done

- [ ] No entry cites "General veterinary advice"; each has a named, linkable source, or is explicitly flagged for human review
- [ ] `grapes` (id 2) corrected to reflect tartaric acid, with an appropriate citation
- [ ] `xylitol`/`peanut butter` alias contradiction resolved
- [ ] `(variant)` duplicate records merged and removed
- [ ] `@known_alias_collisions` shrunk to match what was actually fixed
- [ ] Access dates reflect real re-verification
- [ ] `mix test` green; `mix format --check-formatted` clean
- [ ] A written summary of what changed, what was verified, what could not be verified, and every entry left flagged

## 10. Out of scope

Do not, without asking:

- Change the JSON schema, add or rename fields, or renumber ids
- Reformat or reorder the JSON file wholesale — it makes the diff unreviewable, which is
  the opposite of what a safety dataset review needs
- Touch framework, build, config, or CI files
- Commit, push, or rebase
- Add entries in bulk. Growing the dataset is a separate task; this one is about making
  the existing 170 trustworthy

## 11. Honest caveats

- These numbers come from static analysis of the JSON plus one spot-check (`grapes`).
  **No systematic factual audit of the 170 entries has been performed** — that is the job.
  The 51 "real-cited" entries are cited, not verified.
- The placeholder-citation count (119) is an exact string match on
  `"General veterinary advice"`. Entries with a named source may still be inaccurate,
  outdated, or citing a page that no longer says what it did in July 2025.
- Severity gradings were not assessed at all. The `low`/`medium`/`high` split
  (94/34/42) has no recorded basis and may not reflect any source.
