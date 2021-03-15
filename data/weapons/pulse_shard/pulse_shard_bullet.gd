extends RigidBody

export(float) var projectile_speed =  65.0
export(Array, float) var damage_range = [5.0, 20.0]
export var is_enemy_bullet := false

var starting_position : Vector3 = Vector3.ZERO
var hit_something = false

const bullet_enemy_shader = preload("res://data/weapons/pulse_shard/pulse_shard_bullet_enemy.material")

func _ready():
	if is_enemy_bullet:
		collision_layer = 16
		collision_mask = 1 + 2 + 128
		$MeshInstance.set_material_override(bullet_enemy_shader)
		$free_timer.wait_time = 2.0
	connect("body_entered", self, "collided")
	$free_timer.start()


func _physics_process(delta):
	pass


func _on_free_timer_timeout():
	queue_free()


func start():
	self.starting_position = self.transform.origin
	self.apply_central_impulse( self.global_transform.basis.z * projectile_speed )


func collided(body):
	if hit_something == false:
		#print("HIT ", body.get_path(), " (is_enemy_bullet ", is_enemy_bullet, " )")
		if body.has_method("bullet_hit"):
			body.bullet_hit(self)
	hit_something = true

#	queue_free()

	gravity_scale = 1.0
	if !is_enemy_bullet:
		set_collision_mask_bit(0, true)
		set_collision_mask_bit(3, true)
	else:
		queue_free()

