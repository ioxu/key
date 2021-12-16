extends Spatial
class_name Weapon
# weapons can activate
# weapons dictate damage
# weapons have modifiers

export var weapon_name := "undefined"

export var modifiers = []
export var base_damage = 100.0
export var activated : bool = false setget set_activated, get_activated
export var calculate_global_transform_velocity : bool = false
#export var track_global_transform : bool = false


export var aim_tolerance := 0.05 # based on: 1.0 - (dot product of direction from attacker to target)

var global_velocity := Vector3.ZERO

var _position = Vector3.ZERO

func _ready():
	_position = global_transform.origin


func set_activated(new_value: bool) -> void:
	activated = new_value


func get_activated() -> bool:
	return activated
	

func _process(delta):
	global_velocity =  global_transform.origin - _position
	_position = global_transform.origin
	#prints("global_velocity", global_velocity)
