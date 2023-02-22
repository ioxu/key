extends Node3D
class_name Weapon
# weapons can activate
# weapons dictate damage
# weapons have modifiers

@export var weapon_name := "undefined"

@export var modifiers = []
@export var base_damage = 100.0
@export var activated : bool = false : get = get_activated, set = set_activated
@export var calculate_global_transform_velocity : bool = false
#export var track_global_transform : bool = false


@export var aim_tolerance := 0.05 # based checked: 1.0 - (dot product of direction from attacker to target)

var global_velocity := Vector3.ZERO

var _position := Vector3.ZERO

func _ready():
	_position = global_transform.origin


func set_activated(new_value: bool) -> void:
	activated = new_value


func get_activated() -> bool:
	return activated


func _process(_delta):
	var _gv = global_transform.origin - _position
	if not _gv.is_equal_approx( Vector3.ZERO ):
		global_velocity = Vector3(_gv)
		_position = global_transform.origin
#	pprint("global_velocity %s (%s)"%[global_velocity, self.get_parent().get_parent().get_parent()])


func pprint(thing) -> void:
	print("[weapon] %s"%str(thing))

