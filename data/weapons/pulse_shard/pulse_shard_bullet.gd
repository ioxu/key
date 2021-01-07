extends RigidBody

export(float) var projectile_speed =  4.0
var hit_something = false

func _ready():
	$Area.connect("body_entered", self, "collided")
	$free_timer.start()


#func _process(dt):
#	if not hit_something:
#		translate_object_local(Vector3(0.0, 0.0, projectile_speed * dt))


func _physics_process(delta):
	pass


func _on_free_timer_timeout():
	queue_free()


func start():
	#self.apply_impulse(self.transform.origin - Vector3(0.0, 0.0, -3), self.global_transform.basis.z * -20)
	#self.apply_impulse(self.transform.origin - Vector3(0.0, 0.0, -3), to_global(self.global_transform.basis.z * -40))
	#self.apply_impulse(self.transform.origin - Vector3(0.0, 0.0, -3), Vector3(0.0, 0.0, 1.0)*30.0)
	#self.apply_impulse(self.transform.origin - Vector3(0.0, 0.0, -3), self.global_transform.basis.z * 20)
	#self.apply_impulse(Vector3(0.0, 0.0, -3), self.global_transform.basis.z * 2)
	self.apply_central_impulse( self.global_transform.basis.z * 30 )

func collided(body):
	if hit_something == false:
		print("HIT ", body.get_path())
		if body.has_method("bullet_hit"):
			body.bullet_hit(self)
	hit_something = true
	gravity_scale = 1.0
	set_collision_mask_bit(3, true)
	#queue_free()
