# RAI-38: Review productivity for RAI-34 (M11: Family + Marriage + Kids)

**Reviewer**: Sam Green (CTO)
**Date**: 2026-05-16
**Status**: `done` — all deliverables verified, implementation passes review.

---

## Summary

RAI-34 (M11: Family + Marriage + Kids, owner: Sofia Reyes) is **fully delivered and passes review**. Every deliverable specified in the RAI-32 audit is present, tested, and wired into the existing autoload infrastructure. The code is clean, follows established patterns, and correctly unblocks RAI-35 (M12: Death + Succession).

---

## Deliverable Checklist

| # | Deliverable | File | Status | Notes |
|---|---|---|---|---|
| 1 | `resources/family_tree.gd` — FamilyTree resource | `resources/family_tree.gd` | ✅ Done | members[], active_id, deceased_ids[], get_member_by_id, add_member, mark_deceased, adults(), living(), eligible_heirs() |
| 2 | Update `save_payload.gd` — family_tree field, v2 migration | `scripts/systems/save/save_payload.gd` | ✅ Done | SAVE_VERSION bumped to 4; family_tree + pregnancy_state fields; v1→v2 migration wraps single profile into FamilyTree (v2→v3→v4 added farming/weather/festivals as bonus) |
| 3 | `autoloads/family_manager.gd` — full implementation | `autoloads/family_manager.gd` | ✅ Done | try_conceive, tick_year, age_actor, try_die, move_out_adult_child, succeed_to, pregnancy tracking, marriage signal handler, NPC spouse overrides, serialize/deserialize |
| 4 | `autoloads/game_state.gd` — switch_active_character | `autoloads/game_state.gd` | ✅ Done | switch_active_character(child_id) with heir validation, ensure_family_tree(), family_tree init in start_new_game() |
| 5 | RelationshipManager dating→engaged→married flow | `autoloads/relationship_manager.gd` | ✅ Done | STAGE_THRESHOLDS covers dating(90-94)→engaged(95-98)→married(99-100); propose_marriage() gates on engaged stage, emits marriage_completed |

---

## Test Coverage

| Test file | Scope | Status |
|---|---|---|
| `tests/gut_test_family_manager.gd` | Stage thresholds, aging, conceive requirements, pregnancy duration (14 days), death at max age, blocked death at min age, marriage_completed handler | ✅ Passing |
| `tests/gut_test_save_migration.gd` | v1→v2 migration preserves character + money + time, v2 payload pass-through | ✅ Passing |
| `tests/gut_test_succession.gd` | eligible_heirs filters minors/deceased, inheritance distribution, no-heirs edge case | ✅ Passing (RAI-35 dependency unblocked) |

---

## Code Quality Assessment

### Strengths

- **Clean separation of concerns**: FamilyTree is a pure data Resource; FamilyManager is the autoload orchestrator; GameState holds the active reference. This mirrors the existing pattern (ItemData/InventoryManager, JobData/JobManager, etc.).
- **Defensive programming**: null checks everywhere, snapshot iteration in `tick_year()` to avoid mutation-during-iteration, graceful fallbacks when NPC data files don't exist.
- **Forward compatibility**: FamilyManager's serialize/deserialize supports pregnancy state + NPC overrides. NPC override map (marked RAI-40) shows foresight — spouse relocation is already wired.
- **Two-pass tick_year()**: ages everyone first, then rolls death checks. Prevents cascading death-order bugs.
- **Bidirectional child linkage**: `_complete_pregnancy()` appends child to both parents' children lists.

### Minor Observations (non-blocking)

1. **`FamilyTree.members` typed as `Array[Resource]` not `Array[CharacterProfile]`** — Works in practice since CharacterProfile extends Resource. Swapping to the stricter type would require compile-time class_name resolution that can be brittle at autoload load time. This is acceptable.

2. **`try_conceive()` doesn't emit a signal on success** — The only way UI knows pregnancy started is polling `is_pregnant()`. Consider adding `EventBus.pregnancy_started` for toast/widget feedback. Low priority.

3. **Child ID generation uses `Time.get_unix_time_from_system()`** — Theoretically non-unique if called twice in the same second. Use a GUID or incrementing counter for robustness.

4. **`_on_marriage_completed()` uses string interpolation for NPC data path** (`load("res://data/npcs/%s.tres" % npc_id)`) — Brittle if NPC data files use a different filename convention. Has a fallback (`character_name = npc_id.capitalize()`) so no crash, just missing data.

---

## RAI-35 (M12) Unblock Status

RAI-34 fully unblocks RAI-35. The succession controller, death screen, and succession menu are already present in `scripts/systems/succession_controller.gd` and `ui/menus/succession_menu.gd`, wired through `SceneRouter` (`_setup_succession_controller()` + `_setup_succession_menu()` at scene_router.gd:380-387, 323-330). The FamilyTree.eligible_heirs() method is used directly by the succession controller.

**Note**: `succession_controller.gd` line 69 calls `RelationshipManager._relationships.clear()` — this accesses a private variable (`_relationships`) via direct property access. GDScript permits this since it's a peer autoload, but it bypasses the public API. Consider adding a `reset()` method to RelationshipManager.

---

## Conclusion

RAI-34 is **complete and verified**. All deliverables from the RAI-32 audit scope are implemented, tested, and integrated. The code quality is high, follows the project's established patterns, and correctly unblocks downstream milestones (RAI-35).

**Disposition**: `done`
