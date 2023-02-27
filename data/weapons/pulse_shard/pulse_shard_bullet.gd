extends CharacterBody3D
#extends RigidBody3D

@export var projectile_speed: float =  65.0
@export var projectile_knockback: float =  35.0 * 7.5 
@export var damage_range = [5.0, 20.0] # (Array, float)
@export var is_enemy_bullet := false

var starting_position : Vector3 = Vector3.ZERO
var hit_something = false

const bullet_enemy_shader = preload("res://data/weapons/pulse_shard/pulse_shard_bullet_enemy.material")
const bullet_impact_fx = preload("res://data/weapons/pulse_shard/pulse_shard_bullet_impact_fx.tscn")

func _ready():
	if is_enemy_bullet:
		collision_layer = 16
		collision_mask = 1 + 2 + 128
		$MeshInstance3D.set_surface_override_material(0, bullet_enemy_shader)#set_material_override(bullet_enemy_shader)
		$free_timer.wait_time = 2.0
	#connect("body_entered",Callable(self,"collided"))
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


func collided(body, collision_info: KinematicCollision3D):
	if hit_something == false:
		#print("HIT ", body.get_path(), " (is_enemy_bullet ", is_enemy_bullet, " )")
		if body.has_method("bullet_hit"):
			body.bullet_hit(self, collision_info)
	hit_something = true
	_emit_impact_fx(collision_info)
	call_deferred("queue_free") #queue_free()

#	gravity_scale = 1.0
#	if !is_enemy_bullet:
#		set_collision_mask_value(0, true)
#		set_collision_mask_value(3, true)
#	else:
#		call_deferred("queue_free") #queue_free()


func _emit_impact_fx(collision_info : KinematicCollision3D):
	var impact_fx = bullet_impact_fx.instantiate()
	get_node("/root/").add_child(impact_fx)
	#impact_fx.set_position(collision_info.position + (- self.transform.basis.z * 0.35))
	impact_fx.set_position(collision_info.get_position(0) + (- self.transform.basis.z * 0.35))
#	impact_fx.look_at(collision_info.position - self.transform.basis.z, Vector3.UP)
	impact_fx.look_at(collision_info.get_position(0) - self.transform.basis.z, Vector3.UP)
	if is_enemy_bullet:
		impact_fx.get_node("effect_mesh").material_override.set_shader_parameter("emission", Color(0.953125, 0.349976, 0.349976))
		impact_fx.get_node("OmniLight3D").set_color(Color(0.953125, 0.349976, 0.349976))
	impact_fx.start()
