extends "res://data/pickups/pickup.gd"

export var orb_value := 1

func _ready():
	rng.randomize()
	var r = rng.randf_range(0.5, 1.5)
	$RigidBody/CollisionShape.shape = $RigidBody/CollisionShape.shape.duplicate()
	$RigidBody/MeshInstance.mesh = $RigidBody/MeshInstance.mesh.duplicate()
	
	$RigidBody/CollisionShape.shape.radius = $RigidBody/CollisionShape.shape.radius * r
	$RigidBody/MeshInstance.mesh.radius = $RigidBody/MeshInstance.mesh.radius * r
	$RigidBody/MeshInstance.mesh.height = $RigidBody/MeshInstance.mesh.height * r
