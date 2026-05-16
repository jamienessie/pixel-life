extends Node

# FishingSystem (M9 RAI-37) — fish catalog + weighted roll table.
# UI minigame calls roll_catch(success_quality) to determine the prize.

const _reg_fish_data := preload("res://resources/fish_data.gd")
const FISH_PATH := "res://data/fish/%s.tres"
const FISH_IDS: Array[String] = ["sardine", "bass", "salmon", "tuna", "legendary_pike"]

func get_eligible_fish(season: String, hour: int) -> Array:
	var out: Array = []
	for fish_id in FISH_IDS:
		var f := load_fish(fish_id)
		if f == null:
			continue
		if not f.seasons.is_empty() and not f.seasons.has(season):
			continue
		if not _hour_in_window(hour, f.time_window):
			continue
		out.append(f)
	return out

func _hour_in_window(hour: int, window: Vector2i) -> bool:
	if window.x == 0 and window.y == 24:
		return true
	if window.x <= window.y:
		return hour >= window.x and hour < window.y
	# wrap-around (e.g. 22..2)
	return hour >= window.x or hour < window.y

# success_quality in 0.0..1.0; higher quality biases toward rarer fish.
func roll_catch(season: String, hour: int, success_quality: float, rng: RandomNumberGenerator = null) -> FishData:
	var eligible := get_eligible_fish(season, hour)
	if eligible.is_empty():
		return null
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	# Re-weight: low quality skews to common (high weight), high quality skews to rare (low weight).
	var weights: Array[float] = []
	var total: float = 0.0
	for f in eligible:
		var w: float = float(f.rarity_weight)
		# quality factor: lerp between rarity_weight (q=0) and (1/rarity_weight)*10000 (q=1).
		var rare_bias: float = 10000.0 / max(1.0, w)
		var blended: float = lerp(w, rare_bias, clampf(success_quality, 0.0, 1.0))
		weights.append(blended)
		total += blended
	var pick: float = rng.randf() * total
	var acc: float = 0.0
	for i in eligible.size():
		acc += weights[i]
		if pick <= acc:
			return eligible[i]
	return eligible.back()

func sell_value(fish: FishData, success_quality: float) -> int:
	if fish == null:
		return 0
	var t := clampf(success_quality, 0.0, 1.0)
	return int(round(lerpf(float(fish.min_sell_price), float(fish.max_sell_price), t)))

func load_fish(fish_id: String) -> FishData:
	if fish_id == "":
		return null
	return load(FISH_PATH % fish_id)
