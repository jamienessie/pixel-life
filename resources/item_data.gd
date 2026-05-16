class_name ItemData
extends Resource

# Item definition for the game
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var category: String = ""  # e.g., "tool", "crop", "fish", "cooked", "seeds", "foraged"
@export var stack_size: int = 999
@export var base_buy_price: int = 0
@export var base_sell_price: int = 0
@export var tags: Array = []  # e.g., ["food", "ingredient"]
@export var effects: Dictionary = {}  # e.g., {"energy": 10, "hunger": 5}