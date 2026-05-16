extends Node

# WeatherManager (RAI-49) — daily weather roll per season. Rain auto-waters
# crops via FarmingSystem.water_all_in_zone. Other systems can check
# is_raining() / current_weather() to react (e.g. mood, ambient SFX).

const SEASON_RAIN_PROB := {
	"spring": 0.35,
	"summer": 0.10,
	"autumn": 0.25,
	"winter": 0.05,
}
const SEASON_SNOW_PROB := {
	"spring": 0.0,
	"summer": 0.0,
	"autumn": 0.0,
	"winter": 0.4,
}

# Weather codes: "sun" | "rain" | "snow".
var _weather_today: String = "sun"

signal weather_changed(weather: String)

func _ready() -> void:
	EventBus.day_passed.connect(_on_day_passed)
	_roll(TimeManager.season)

func _on_day_passed(_day: int, season: String, _year: int) -> void:
	_roll(season)
	if _weather_today == "rain":
		# Rain auto-waters every farm zone with crops.
		for zone_id in ["farm"]:
			FarmingSystem.water_all_in_zone(zone_id)
		AudioManager.play_sfx("sfx_rain_ambience")
	elif _weather_today == "snow":
		AudioManager.play_sfx("sfx_wind_cold")

func _roll(season: String) -> void:
	var r := randf()
	var rain_p: float = SEASON_RAIN_PROB.get(season, 0.1)
	var snow_p: float = SEASON_SNOW_PROB.get(season, 0.0)
	var new_weather: String
	if r < rain_p:
		new_weather = "rain"
	elif r < rain_p + snow_p:
		new_weather = "snow"
	else:
		new_weather = "sun"
	if new_weather != _weather_today:
		_weather_today = new_weather
		weather_changed.emit(_weather_today)

func current_weather() -> String:
	return _weather_today

func is_raining() -> bool:
	return _weather_today == "rain"

func is_snowing() -> bool:
	return _weather_today == "snow"

func serialize() -> Dictionary:
	return {"weather_today": _weather_today}

func deserialize(data: Dictionary) -> void:
	_weather_today = data.get("weather_today", "sun")
