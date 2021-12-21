extends "res://data/pickups/pickup.gd"

export (PackedScene) var weapon_archetype
var weapon = null

func _ready():
	weapon = weapon_archetype.instance()
	weapon.transform.origin = Vector3(0.0, 0.0, 0.5)
	#weapon.set_activated( true )
	$RigidBody.add_child( self.weapon )


func _process(dt):
	pass


