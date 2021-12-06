extends Spatial

# pickup-type object based on RiginBody base

export var pickup_name := "Gem"
export var orb_value := 1

var magnet_to = null
var magnet_time = 0.0

onready var rb = $RigidBody

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var r = rng.randf_range(0.5, 1.5)
	prints("RAND",r)
	$RigidBody/CollisionShape.shape = $RigidBody/CollisionShape.shape.duplicate()
	$RigidBody/MeshInstance.mesh = $RigidBody/MeshInstance.mesh.duplicate()
	
	$RigidBody/CollisionShape.shape.radius = $RigidBody/CollisionShape.shape.radius * r
	$RigidBody/MeshInstance.mesh.radius = $RigidBody/MeshInstance.mesh.radius * r
	$RigidBody/MeshInstance.mesh.height = $RigidBody/MeshInstance.mesh.height * r


func _physics_process(dt):
	if magnet_to:
		magnet_time += dt
		if magnet_time < 0.15:
			rb.apply_central_impulse(Vector3(0.0, 25, 0.0))
		else:
			var to = magnet_to.global_transform.origin - rb.global_transform.origin
			to = to.normalized() * 15
			to += Vector3(0.0, 10, 0.0)
			rb.apply_central_impulse(to)


func _on_orb_pickup_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("pickup"):
			body.pickup(self)
		self.queue_free()


func _on_magnet_area_body_entered(body):
	if body.is_in_group("Player") and magnet_to == null:
		magnet_to = body

