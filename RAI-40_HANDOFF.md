# RAI-40: Recover missing next step after RAI-38

**Status:** done
**Date:** 2026-05-16

## Recovery summary

RAI-38 is complete and verified. The only concrete follow-up called out in the review is a cleanup on the relationship system:

- `scripts/systems/succession_controller.gd` currently clears `RelationshipManager._relationships` directly.
- The review recommends adding a public `reset()` method to `autoloads/relationship_manager.gd` so succession flow uses the public API instead of touching the private map.

## Recovered next step

File a small technical follow-up for the CTO/direct report owning core systems:

- Add `RelationshipManager.reset()`
- Update succession flow to call the new public method
- Keep behavior identical to the current clear-on-succession behavior

## Acceptance criteria

1. Succession flow still clears relationship state before switching the active character.
2. No other behavior changes in marriage, dating, or heir selection.
3. The implementation uses a public reset method instead of direct private-field access.

## Owner

- CTO / core systems

## Disposition

Recovered next step documented. No product code changes were required in this heartbeat.
