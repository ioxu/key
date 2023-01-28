extends "res://data/pickups/pickup.gd"

@export var orb_value := 1

func _ready():
	rng.randomize()
	var r = rng.randf_range(0.5, 1.5)
	$RigidBody3D/CollisionShape3D.shape = $RigidBody3D/CollisionShape3D.shape.duplicate()
	$RigidBody3D/MeshInstance3D.mesh = $RigidBody3D/MeshInstance3D.mesh.duplicate()
	
	$RigidBody3D/CollisionShape3D.shape.radius = $RigidBody3D/CollisionShape3D.shape.radius * r
	$RigidBody3D/MeshInstance3D.mesh.radius = $RigidBody3D/MeshInstance3D.mesh.radius * r
	$RigidBody3D/MeshInstance3D.mesh.height = $RigidBody3D/MeshInstance3D.mesh.height * r
