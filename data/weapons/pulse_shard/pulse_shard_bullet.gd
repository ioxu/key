extends KinematicBody
#extends RigidBody

export(float) var projectile_speed =  65.0
export(float) var projectile_knockback =  35.0 * 7.5 
export(Array, float) var damage_range = [5.0, 20.0]
export var is_enemy_bullet := false

var starting_position : Vector3 = Vector3.ZERO
var hit_something = false

const bullet_enemy_shader = preload("res://data/weapons/pulse_shard/pulse_shard_bullet_enemy.material")
const bullet_impact_fx = preload("res://data/weapons/pulse_shard/pulse_shard_bullet_impact_fx.tscn")

func _ready():
	if is_enemy_bullet:
		collision_layer = 16
		collision_mask = 1 + 2 + 128
		$MeshInstance.set_material_override(bullet_enemy_shader)
		$free_timer.wait_time = 2.0
	#connect("body_entered", self, "collided")
	$free_timer.start()


func _physics_process(delta):
	var collision_info = move_and_collide( delta * self.global_transform.basis.z * projectile_speed )
	if collision_info:
		collided(collision_info.get_collider(), collision_info)
#	pass

func _on_free_timer_timeout():
	queue_free()


func start():
	self.starting_position = self.transform.origin
	#self.apply_central_impulse( self.global_transform.basis.z * projectile_speed )


func collided(body, collision_info: KinematicCollision):
	if hit_something == false:
		#print("HIT ", body.get_path(), " (is_enemy_bullet ", is_enemy_bullet, " )")
		if body.has_method("bullet_hit"):
			body.bullet_hit(self, collision_info)
	hit_something = true
	_emit_impact_fx(collision_info)
	call_deferred("queue_free") #queue_free()

#	gravity_scale = 1.0
#	if !is_enemy_bullet:
#		set_collision_mask_bit(0, true)
#		set_collision_mask_bit(3, true)
#	else:
#		call_deferred("queue_free") #queue_free()


func _emit_impact_fx(collision_info : KinematicCollision):
	var impact_fx = bullet_impact_fx.instance()
	get_node("/root/").add_child(impact_fx)
	impact_fx.set_translation(collision_info.position + (- self.transform.basis.z * 0.35))
	impact_fx.look_at(collision_info.position - self.transform.basis.z, Vector3.UP)
	if is_enemy_bullet:
		impact_fx.get_node("MeshInstance").material_override.set_shader_param("emission", Color(0.953125, 0.349976, 0.349976))
		impact_fx.get_node("OmniLight").set_color(Color(0.953125, 0.349976, 0.349976))
