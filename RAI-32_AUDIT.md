# RAI-32: Pixel Town — Audit of Game Progress & Blocked Work

**Auditor**: Sam Green (CTO)
**Date**: 2026-05-15
**Status**: `done` (findings documented; implementation work delegated)

---

## Summary

Milestones M1–M8 are substantially delivered. The core loop (walking, time, needs, inventory, NPC dialogue/schedules, save/load) is in place and test-covered. Work stalls at three transition points that each require one or more resource-class definitions plus manager logic before downstream milestones can proceed.

---

## Delivered & Working

| Milestone | Scope | Status | Notes |
|---|---|---|---|
| M1 | Project skeleton, 14 autoloads, input map, display 320×180 | ✅ Done | All autoloads registered, input actions configured |
| M2 | Tilemap + walking player | ✅ Done | town.tscn with procedural tiles, Player/YSort/Camera, zone transitions |
| M3 | TimeManager + HUD clock | ✅ Done | Clock advances, pause menu works |
| M4 | Zone transitions (4 zones) | ✅ Done | farm/forest/beach scenes, SceneRouter fade-swaps |
| M5 | Needs system + sleep | ✅ Done | 5 needs with decay, sleep advances to 06:00 |
| M6 | Save/Load (single char, no FamilyTree) | ✅ Done | .tres + .json sidecar, auto-save on sleep/quit, Continue works |
| M7 | Inventory + Economy + starter items | ✅ Done (RAI-26) | 10 items, 6×4 grid, EconomyManager price lookup, HUD wired |
| M8 | NPCs + dialogue + schedules | ✅ Done | 3 NPCs (anna/bryan/cora), DialogueData, ScheduleData, NPCScheduleRunner |

**Test coverage**: GUT tests exist for time_manager tick boundaries, needs decay, save roundtrip (v1→v2 migration), inventory edge cases, relationship stage transitions, inheritance rules.

---

## Blocked Transition Points

### 1. M9 blocked — no JobData/CareerTrackData resources, no job data files

**What's missing:**
- `resources/job_data.gd` — class_name JobData with fields: id, name, category, shift_hours, shift_days, base_pay_per_shift, requires_education, career_track, resolution, minigame_scene
- `resources/career_track_data.gd` — class_name CareerTrackData with levels[] of {title, pay, days_required, performance_required}
- `data/jobs/` — needs at least 1 job per category: cashier (service, auto-check), farmer (self-employed, crop minigame), painter (creative, easel produces art), doctor (skilled, requires school)
- `autoloads/job_manager.gd` — stub methods have comments "TODO: Implement (M9)", needs real apply_for/try_promote logic

**Impact**: Careers, performance, paychecks, fame system cannot advance until jobs are defined.

**Owner for next step**: Sofia Reyes (assigned as previous M implementer)

---

### 2. M11 blocked — no FamilyTree in SavePayload, no family data resources

**What's missing:**
- `resources/family_tree.gd` (or extend CharacterProfile) — members[], active_id, deceased_ids[], get_member_by_id()
- `SavePayload.family_tree` field (currently at SAVE_VERSION=1, no migration needed yet since no v2)
- `autoloads/family_manager.gd` — all methods are stub TODOs: try_conceive, tick_year, age_actor, try_die, move_out_adult_child, succeed_to
- `autoloads/game_state.gd` — switch_active_character is stub TODO

**Impact**: Marriage → pregnancy → kids → aging pipeline is frozen. Death/succession (M12) cannot begin.

**Owner for next step**: Sofia Reyes

---

### 3. M12 blocked — succession UI + death check + inheritance integration

**Dependencies**: M11 (FamilyTree + switch_active_character must exist first)
**What's missing:**
- Succession UI (prompt listing eligible adult children after death)
- `FamilyManager.try_die` — LIFE_EXPECTANCY_MIN/MAX death probability logic
- `scripts/systems/save/inheritance_rules.gd` integration into succession flow
- Adult-child move-out option (tier-1 apartment)

**Note**: `scripts/systems/save/inheritance_rules.gd` and `tests/gut_test_inheritance_rules.gd` already exist and pass; the logic is ready, it just needs to be wired into the death/succession flow once M11 is done.

---

## Minor Gaps (non-blocking)

| Item | Location | Fix |
|---|---|---|
| SaveManager references `resources/character_profile.gd` via load but .tres files exist in `data/` | `autoloads/save_manager.gd:8` | Works because CharacterProfile is a GDScript class (not .tres); clarify if both needed |
| No crop_data.gd resource | `resources/` | Needed for M9 farming; can be added alongside job resources |
| NPCScheduleRunner polls every 15 min; works but not visually smooth for schedule changes | `scripts/systems/npc/npc_schedule_runner.gd:19` | Low priority; acceptable for scope |
| Missing 5 resource classes from PLAN.txt | `resources/` | crop_data, recipe_data, audio_track_data — low priority until their milestones |

---

## Suggested Task Order

### RAI-33 — M9: Jobs + Careers (child issue, owner: Sofia Reyes)

**Blocker**: No JobData/CareerTrackData resource classes, no job data files, JobManager stub.

**Deliverables**:
1. `resources/job_data.gd` — class_name JobData, fields: id, name, category, shift_hours (Vector2i), shift_days[], base_pay_per_shift, requires_education, career_track, resolution ("auto"|"minigame"|"skill_check"), minigame_scene
2. `resources/career_track_data.gd` — class_name CareerTrackData, fields: id, levels[] of {title, pay, days_required, performance_required}
3. `data/jobs/` — 4 job files:
   - `cashier.tres` (service, auto resolution)
   - `farmer.tres` (self-employed, crop actions)
   - `painter.tres` (creative, easel produces ItemData art)
   - `doctor.tres` (skilled, requires school)
4. `autoloads/job_manager.gd` — implement: `apply_for(job_id)`, `try_promote()`, full shift cycle with payout/performance

**Test**: Hold each job type → earn money → promotions trigger.

---

### RAI-34 — M11: Family + Marriage + Kids (child issue, owner: Sofia Reyes)

**Blocker**: No FamilyTree in SavePayload, FamilyManager all stubs, switch_active_character stub.

**Deliverables**:
1. `resources/family_tree.gd` — class_name FamilyTree, fields: members[] (CharacterProfile), active_id, deceased_ids[], `get_member_by_id(id)`
2. Update `scripts/systems/save/save_payload.gd` — add `family_tree: FamilyTree` field, bump SAVE_VERSION to 2, add v1→v2 migration in SaveManager
3. `autoloads/family_manager.gd` — implement: `try_conceive()`, `tick_year()` (listen to year_passed), `age_actor()`, `try_die()` (M12 prerequisite)
4. `autoloads/game_state.gd` — implement `switch_active_character(child_id)`
5. RelationshipManager: dating→engaged→married flow, spouse schedule override

**Test**: Date NPC → marry → conceive → child born → child ages baby→child→teen→adult.

---

### RAI-35 — M12: Death + Succession (child issue, owner: Sofia Reyes)

**Blocker**: Depends on RAI-34 (FamilyTree + switch_active_character must exist first).

**Deliverables**:
1. Succession UI scene + prompt listing eligible adult children after `player_died`
2. `FamilyManager.try_die` — LIFE_EXPECTANCY_MIN/MAX probability, guaranteed death at MAX
3. Wire `scripts/systems/save/inheritance_rules.gd` into succession flow
4. Adult-child move-out (tier-1 apartment)
5. "No heirs" restart path

**Test**: `time_scale=600` → hit death → succession UI → play as adult child → verify inheritance.

---

## Verification

No gameplay verification was run (this was an audit of existing code). The test suite covers individual systems but there is no end-to-end smoke test documented for M1–M8. Recommend running Godot and playing through the boot → main_menu → town → sleep → quit → continue cycle to confirm.

---

*RAI-32 done — implementation work on M9/M11/M12 delegated to child issues.*

## CEO handoff note

Recovered next step for the stalled chain:

- RAI-33 owns M9 jobs/careers and should go to CTO/Sofia Reyes.
- RAI-34 owns M11 family/marriage/kids and should go to CTO/Sofia Reyes.
- RAI-35 owns M12 death/succession and depends on RAI-34.

Disposition for the parent recovery work: `done`. The durable next action is implementation on the three child issues above.
