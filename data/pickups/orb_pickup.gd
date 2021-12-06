extends RigidBody

# pickup-type object based on RiginBody base

export var pickup_name := "Orb"
export var orb_value := 1

var magnet_to = null
var magnet_time = 0.0


func _ready():
	pass


func _physics_process(dt):
	if magnet_to:
		magnet_time += dt
		if magnet_time < 0.15:
			self.apply_central_impulse(Vector3(0.0, 25, 0.0))
		else:
			var to = magnet_to.global_transform.origin - self.global_transform.origin
			to = to.normalized() * 15
			to += Vector3(0.0, 10, 0.0)
			self.apply_central_impulse(to)


func _on_orb_pickup_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("pickup"):
			body.pickup(self)
		self.queue_free()


func _on_magnet_area_body_entered(body):
	if body.is_in_group("Player") and magnet_to == null:
		magnet_to = body

