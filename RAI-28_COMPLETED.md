# RAI-28: Recover stalled issue RAI-6

**Status: done**
**Completed by: Sofia Reyes**
**Date: 2026-05-15**

## Problem
RAI-6 (M6: Save/Load) was stalled due to a critical bug in `save_manager.gd` that prevented character identity from being preserved through save-load-save cycles. The Continue flow also did not restore the player's saved position.

## Root Cause

### Bug 1: Inverted duck-type check in `save_manager.gd:28`
The original code checked `GameState.active_character.has_method("get") == false` to determine if the active character was a "real" Resource with `id`. Since `CharacterProfile` inherits from `Resource` → `Object`, which has a built-in `get()` method, `has_method("get")` returned `true`, making `== false` evaluate to `false`. This caused the code to fall through to the `else` branch, writing default values (`"player_001"` / `"Player"`) instead of the actual character data.

**Fix**: Simplified the check to directly test `GameState.active_character.get("id") != null`, removing the inverted `has_method` guard.

### Bug 2: Continue flow ignored saved position
`main_menu.gd._on_continue_button_pressed()` called `SceneRouter.goto_zone(zone, "spawn_default")` which always placed the player at the zone's default spawn marker, ignoring the saved `last_position_x`/`last_position_y` on the `CharacterProfile`.

**Fix**: After awaiting the zone transition, call `_restore_player_position()` to set the player's global position from the saved profile.

## Changes

### `autoloads/save_manager.gd`
- Fixed character profile save logic: replaced inverted `has_method("get") == false` check with direct `get("id") != null` check (`save_manager.gd:28`)
- Removed unused `_get_active_name()` dead code

### `scenes/main/main_menu.gd`
- Added `await` on `SceneRouter.goto_zone()` to ensure the zone is fully loaded before positioning
- Added `_restore_player_position()` helper that applies saved `last_position_x/y` to the player after zone load

## Verification
- Save round-trip test (`tests/test_save_roundtrip.gd` and `tests/gut_test_save_roundtrip.gd`) — verifies constants, default state, payload creation, field integrity, signals, and disk round-trip
- Scenario: New Game → walk → quit → Continue — should restore time, position, needs, money, inventory, and character identity
- Auto-save on sleep: wired in `save_manager.gd:139-140` (requires M5 sleep flow to emit `sleep_completed`)
- Auto-save on quit: wired via `NOTIFICATION_WM_CLOSE_REQUEST` (`save_manager.gd:13-15`)

## Remaining (outside M6 scope)
- `sleep_completed` signal is never emitted yet — needs `bed.tscn` interactable from M5
- `SavePayload` fields `family_tree, world_state, unlocks, settings` deferred to M11
