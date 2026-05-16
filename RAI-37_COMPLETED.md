# RAI-37: M9 — Fishing System

**Status:** done
**Completed by:** Sofia Reyes / Sam Green (CTO — recovery)
**Date:** 2026-05-16

---

## Summary

RAI-37 delivered the full fishing system for M9: FishData resource, FishingSystem autoload, fishing minigame UI, fishing spot interactables placed in the beach zone, fish data files, and fish item data. The player starts with a fishing rod (starter inventory) and can fish at the beach immediately.

---

## Deliverables

### 1. Resource class — `resources/fish_data.gd`
- `class_name FishData extends Resource`
- Fields: id, name, item_id, seasons, time_window, rarity_weight, min_sell_price, max_sell_price, difficulty

### 2. Fish catalog — `data/fish/*.tres` (5 species)
| Fish | Seasons | Time Window | Rarity | Sell Range |
|------|---------|-------------|--------|------------|
| Sardine | Any | 0–24 | Common (240) | 10–20 |
| Bass | Spring, Summer, Autumn | 6–22 | Medium (120) | 25–50 |
| Salmon | Autumn | 6–19 | Uncommon (80) | 70–130 |
| Tuna | Summer | 8–16 | Rare (30) | 180–280 |
| Legendary Pike | Winter | 22–24 | Legendary (5) | 800–1500 |

### 3. Fish items — `data/items/*.tres` (5 fish + 1 cooked recipe)
- `sardine.tres`, `bass.tres`, `salmon.tres`, `tuna.tres`, `legendary_pike.tres`
- `fish_sandwich.tres` (cooked recipe: hunger 40, energy 10)

### 4. FishingSystem autoload — `scripts/systems/fishing/fishing_system.gd`
- Registered as `FishingSystem` autoload in `project.godot:30`
- `get_eligible_fish(season, hour)` — filters by season and time-of-day window
- `roll_catch(season, hour, success_quality, rng)` — weighted random roll with quality bias
- `sell_value(fish, success_quality)` — linear interpolation between min/max price
- `load_fish(fish_id)` — loads from `data/fish/%s.tres`

### 5. Fishing spot interactable — `scripts/interactables/fishing_spot.gd` + `scenes/interactables/fishing_spot.tscn`
- Extends Area2D, added to `interactable` group
- Checks `InventoryManager.count("fishing_rod") > 0` before opening minigame
- Shows "[E] Fish" prompt when player is in range
- 3 spots placed in `scenes/world/beach.tscn` at (96,240), (160,256), (224,248)

### 6. Fishing minigame UI — `ui/menus/fishing_minigame.gd` + `.tscn`
- Timing-bar style: oscillating cursor moves along a horizontal bar
- Player presses INTERACT (E/Space) to lock in
- 3 attempts per cast; each attempt randomizes the target zone position
- Best quality determines fish rarity via FishingSystem.roll_catch()
- Pauses time during minigame (`TimeManager.pause_time()` / `resume_time()`)
- Emits `EventBus.item_acquired` on successful catch

### 7. Starter inventory — `autoloads/game_state.gd:29`
- `fishing_rod` added to starter inventory so fishing is reachable on day 1

### 8. Tests — `tests/gut_test_fishing.gd` (5 tests)
- `test_eligible_filters_by_season` — sardine year-round, tuna/salmon seasonal
- `test_eligible_filters_by_time_window` — tuna excluded before 8h
- `test_legendary_pike_winter_midnight_window` — legendary pike winter-only at 22–24
- `test_roll_returns_eligible_fish` — seeded roll returns in-season fish
- `test_sell_value_lerps_min_max` — sell_value at quality 0/1 matches min/max prices

---

## Integration Points

| System | Integration |
|--------|------------|
| `TimeManager` | Minigame pauses/resumes time during play |
| `InventoryManager` | Fishing spot checks for rod; minigame adds caught fish |
| `EventBus.item_acquired` | Emitted on successful catch |
| `InputActions.INTERACT` | Minigame uses INTERACT for lock-in |
| `PlayerController._try_interact_generic()` | Proximity-based interaction with fishing spots |
| `InteractablePrompt` | Shows "[E] Fish" when player approaches spot |
| `GameState._grant_starter_inventory()` | Fishing rod granted on new game |

---

## Remaining / Follow-up

None within fishing scope. The fishing system is complete and integrated.

Related M9 work tracked separately:
- **RAI-33** — M9 Jobs/Careers (JobData, CareerTrackData, 4 jobs)
- **M9 Farming** — `FarmingSystem`, `crop_tile.gd` (wired into farm.tscn)
- **M9 School** — `SchoolSystem`, school.tscn
- **M9 Library** — `LibrarySystem`, library.tscn
