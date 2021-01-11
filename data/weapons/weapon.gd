extends Spatial
# weapons can activate
# weapons dictate damage
# weapons have modifiers

export var modifiers = []
export var base_damage = 100.0
export var activated : bool = false setget set_activated, get_activated


func set_activated(new_value: bool) -> void:
	activated = new_value


func get_activated() -> bool:
	return activated
	
