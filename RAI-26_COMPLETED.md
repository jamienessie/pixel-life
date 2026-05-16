# RAI-26: Recover missing next step RAI-7

**Status: done**
**Completed by: Sofia Reyes**
**Date: 2026-05-15**

## Problem
RAI-7 (M7: Inventory + Economy) delivered the backend singletons (InventoryManager, EconomyManager) but was missing the player-facing UI layer and several M7-spec items.

## Concrete Deliverables

### 1. EconomyManager price lookup (fixed)
- `autoloads/economy_manager.gd` — `price_of()` and `sell_value()` now load ItemData resources instead of returning 0.

### 2. Starter item catalog (expanded)
- `data/items/` grew from 2 to 10 items:
  - `wood.tres` (material, 99 stack)
  - `stone.tres` (material, 99 stack)
  - `fiber.tres` (foraged, 99 stack)
  - `tomato.tres` (crop, food, restores hunger)
  - `corn.tres` (crop, food, restores hunger)
  - `tomato_seeds.tres` (seeds, spring/summer)
  - `corn_seeds.tres` (seeds, summer/autumn)
  - `fishing_rod.tres` (tool, stack=1)

### 3. Inventory menu UI (new)
- `ui/menus/inventory_menu.gd` — full 6×4 grid built in code, toggles with MENU (I) key, shows item name + quantity per slot, category-colored icon rects, click-to-drop interaction.
- `ui/menus/inventory_menu.tscn` — scene with dark overlay, centered panel, grid container layout.

### 4. HUD wiring (fixed)
- `ui/hud/hud.tscn` — now includes `MoneyWidget` and `NeedsBars` (both existed as scenes but were orphaned from the HUD).

### 5. SceneRouter integration (new)
- `autoloads/scene_router.gd` — `_setup_inventory_menu()` instantiates the inventory menu into the persistent UI layer, hides it alongside the HUD on zone clear.

## Deferred (natural fit for M8)
- Shop UI + debug shopkeeper NPC — requires NPC scenes and the interaction system, which are M8 deliverables.
