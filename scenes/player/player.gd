extends KinematicBody

export var initial_health : float = 1000.0
var health : float setget set_health
export var targetable := true
export var active := true setget set_active, get_active

var damage_rng = RandomNumberGenerator.new()
onready var hurt_meter = $MeshInstance/hurt_meter

export (NodePath) var spawn_point

var current_wepon = null

func _ready():
	spawn_point = get_node(spawn_point)
	damage_rng.randomize()
	health = initial_health
	$icons/death_icon.visible = false
	targetable = visible

	# connect to weapon
	current_wepon = $MeshInstance/weapon_mount.get_child(0)
	current_wepon.connect("fire", self, "_on_weapon_fire")

func set_active(new_value):
	active = new_value
	$CollisionShape.disabled = !new_value
	targetable = new_value
	$Controller.set_physics_process(new_value)
	$Controller.set_process(new_value)
	$Controller.set_process_input(new_value)
	$Controller.set_process_unhandled_input(new_value)
	$Controller.weapon.activated = false


func get_active():
	return active


func set_health(new_value):
	health = new_value
	hurt_meter.set_factor( 1.0 - health/initial_health )
	if health <= 0.0:
		die()


func die():
	$MeshInstance/hurt_meter.visible = false
	$icons/death_icon.visible = true
	set_active(false)
	yield(get_tree().create_timer(1.5), "timeout")
	visible = false
	spawn_point.transport_player_to_spawn_point()


func respawn():
	set_health(initial_health)
	set_active(true)
	$MeshInstance/hurt_meter.visible = true
	$icons/death_icon.visible = false
	visible = true


func _on_weapon_fire(weapon):
	#print(weapon.get_path(), " fired! ")
	$Controller.additional_force += -current_wepon.bullet_spawner.global_transform.basis.z.normalized() * weapon.fire_kickback


func bullet_hit(bullet, collision_info):
	if !get_active():
		return

	# kockback
	$Controller.additional_force += bullet.global_transform.basis.z.normalized() * bullet.projectile_knockback * 0.5

	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	set_health( health - damage )

