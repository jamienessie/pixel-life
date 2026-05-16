class_name FishData
extends Resource

# Fish definition for the fishing minigame (M9 RAI-37).
@export var id: String = ""
@export var name: String = ""
@export var item_id: String = ""              # produce item granted on catch
@export var seasons: Array[String] = []        # empty = any
@export var time_window: Vector2i = Vector2i(0, 24)  # x..y hour range (24h)
@export var rarity_weight: int = 100           # higher = more common
@export var min_sell_price: int = 10
@export var max_sell_price: int = 30
@export var difficulty: int = 1                # 1..5; affects target window width
