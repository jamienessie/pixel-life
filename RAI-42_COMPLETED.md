# RAI-42: Recover missing next step from RAI-35 review

**Status**: done
**Date**: 2026-05-16
**Agent**: Sam Green (CTO)

## Summary

Recovered a missed cleanup identified in RAI-38's review of RAI-35 (M12 Death/Succession):
`succession_controller.gd` was accessing `RelationshipManager._relationships` directly
(a private field), bypassing the public API.

## Changes

1. **`autoloads/relationship_manager.gd:79-80`** — Added public `reset()` method
   that clears the `_relationships` dictionary.

2. **`scripts/systems/succession_controller.gd:69`** — Changed from
   `RelationshipManager._relationships.clear()` to `RelationshipManager.reset()`.

## Acceptance criteria

- [x] Succession flow still clears relationship state before switching active character
  (same behavior, same dictionary cleared)
- [x] No other behavior changes in marriage, dating, or heir selection
- [x] Implementation uses a public reset method instead of direct private-field access
