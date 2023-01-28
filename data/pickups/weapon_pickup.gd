extends "res://data/pickups/pickup.gd"

#@export (PackedScene) var weapon_archetype
@export  var weapon_archetype:PackedScene

var weapon = null

func _ready():
	pprint("weapon archetype %s"%weapon_archetype)
	weapon = weapon_archetype.instantiate()
	pprint("weapon %s"%weapon)
	weapon.transform.origin = Vector3(0.0, 0.0, 0.5)
	#weapon.set_activated( true )
	$RigidBody3D.add_child( self.weapon )
	weapon.randomize_color()
	pass

func _process(dt):
	pass

func pprint(thing) -> void:
	print("[weapon pickup] %s"%str(thing))
