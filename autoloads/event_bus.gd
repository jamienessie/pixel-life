extends Node

# Signal hub — canonical signal contracts for Pixel Life.
# Coordinate with Sofia Reyes before adding new signals.

# Time signals
signal minute_passed(minute: int)
signal hour_passed(hour: int)
signal day_passed(day: int, season: String, year: int)
signal season_changed(season: String)
signal year_passed(year: int)

# Economy signals
signal money_changed(total: int, delta: int)

# Needs signals
signal need_changed(need: String, value: float)
signal need_critical(need: String)

# Inventory signals
signal inventory_changed
signal item_acquired(item_id: String, qty: int)

# Relationship signals
signal relationship_changed(npc_id: String, value: float, stage: String)
signal marriage_completed(npc_id: String)

# Dialogue signals
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)

# Job signals
signal job_assigned(job_id: String)
signal shift_started
signal shift_ended(payout: int, performance: float)
signal job_level_up(job_id: String, new_level: int)

# Housing signals
signal house_upgraded(tier: int)

# Life-cycle signals
signal player_died(cause: String)
signal child_born(child_id: String)
signal child_aged(child_id: String, stage: String)
signal playable_character_switched(new_actor_id: String)

# Zone signals
signal zone_changed(zone_id: String)

# Save signals
signal save_requested
signal save_completed
signal load_completed

# Sleep signals
signal sleep_requested
signal sleep_completed
