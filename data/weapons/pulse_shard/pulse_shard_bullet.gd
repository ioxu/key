extends RigidBody

export(float) var projectile_speed =  65.0
export(Array, float) var damage_range = [5.0, 20.0]
var hit_something = false

func _ready():
	$Area.connect("body_entered", self, "collided")
	$Area.connect("area_entered", self, "collided")
	$free_timer.start()


func _physics_process(delta):
	pass


func _on_free_timer_timeout():
	queue_free()


func start():
	self.apply_central_impulse( self.global_transform.basis.z * projectile_speed )


func collided(body):
	if hit_something == false:
		print("HIT ", body.get_path())
		if body.has_method("bullet_hit"):
			body.bullet_hit(self)
	hit_something = true
	gravity_scale = 1.0
	set_collision_mask_bit(3, true)
	#queue_free()
