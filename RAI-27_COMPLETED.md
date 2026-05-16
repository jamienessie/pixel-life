# RAI-27: Recover stalled issue RAI-24 (M8: NPCs + Dialogue + Schedules)

**Status: done**
**Completed by: Sam Green (CTO)**
**Date: 2026-05-15**

## Problem
RAI-24 (M8: NPCs + Dialogue + Schedules) stalled with no deliverables. The 14 autoloads existed from M1 but DialogueManager and RelationshipManager were stubs. No NPC data, scenes, or dialogue UI existed.

## Deliverables

### 1. Resource scripts (3 new files)
- `resources/npc_data.gd` — NPCData with gift tiers, personality, schedule/dialogue links
- `resources/dialogue_data.gd` — DialogueData with node-based tree structure
- `resources/schedule_data.gd` — ScheduleData with time entries and seasonal overrides

### 2. Starter NPC data (9 .tres files)
- 3 NPC definitions in `data/npcs/`: anna, bryan, cora — each with home zone, gift preferences, personality tags
- 3 dialogue trees in `data/dialogue/`: branching conversations per NPC with greet/choice/farewell flow
- 3 schedules in `data/schedules/`: time-of-day position entries per NPC

### 3. NPC system
- `scenes/actors/npc.tscn` + `scripts/actors/npc_controller.gd` — CharacterBody2D with animated sprite, interaction area, target-based movement
- `scripts/systems/npc/npc_schedule_runner.gd` — polls TimeManager every hour/15min, routes NPCs to schedule positions
- `scripts/systems/npc/npc_spawner.gd` — zone-filtered NPC instantiation with cleanup on zone change

### 4. UI
- `ui/menus/dialogue_box.tscn` + `.gd` — overlay with speaker name, text, choice buttons, keyboard continue
- `ui/menus/relationship_menu.tscn` + `.gd` — scrollable list showing name, progress bar (value), and stage label per NPC

### 5. Autoload rewrites
- `autoloads/dialogue_manager.gd` — full dialogue tree traversal (load → get_current_node → choose → end), dialogue_started/ended signals, time pause during dialogue
- `autoloads/relationship_manager.gd` — value-based stage progression (stranger→acquaintance→friend→close_friend→dating→engaged→married), marriage proposal, stage thresholds exposed
- `autoloads/scene_router.gd` — wired dialogue box, relationship menu, NPC spawner, and schedule runner into the persistent UI layer and zone transitions

### 6. Player controller
- `scripts/actors/player_controller.gd` — interaction key (E/Space) detects nearest NPC within 32px range, triggers dialogue; movement frozen during dialogue

### 7. Tests
- `tests/test_dialogue_system.gd` — initial state, start dialogue, get_current_node, choice advancement, farewell end, invalid index
- `tests/test_npc_spawner.gd` — validates all 3 NPC data files, dialogue links, schedule entry structure

## Not covered (intentional)
- Shop UI + debug shopkeeper NPC — deferred per RAI-26, requires the full M8 NPC foundation laid here
- NPC sprite assets — code falls back to player_sprites.png when individual NPC sprites are missing
- NavigationAgent2D pathfinding — NPCs use direct target movement; pathfinding can be added as a follow-up
