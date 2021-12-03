extends RigidBody

export var pickup_name := "Orb"

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
		#prints(body.get_name(), "has picked up", self.get_name())
		self.queue_free()
		pass


func _on_magnet_area_body_entered(body):
	if body.is_in_group("Player") and magnet_to == null:
		#prints(self.get_name(), "will magnet to", body.get_name())
		magnet_to = body
