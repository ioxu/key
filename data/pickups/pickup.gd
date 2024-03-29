extends Node3D

@export var pickup_type := "Undefined"
@export var magnet := true
@export var magnet_radius := 7.5

var magnet_to = null
var magnet_time = 0.0

@onready var rb = $RigidBody3D

var rng = RandomNumberGenerator.new()


func _ready():
	pass


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


func apply_central_impulse(impulse: Vector3 = Vector3(0.0, 1.0, 0.0)) -> void:
	$RigidBody3D.apply_central_impulse( impulse )
	
	
	
	
