extends KinematicBody

export var initial_health : float = 1000.0
var health : float setget set_health
export var targetable := true
export var active := true setget set_active, get_active

var damage_rng = RandomNumberGenerator.new()
onready var hurt_meter = $MeshInstance/hurt_meter

#export (NodePath) var spawn_point

export var recoil_time := 0.0 # animated by recoil_animplayer
var recoil_magnitude := 0.65#0.65#0.35

onready var body = $MeshInstance
onready var body_initial_position = body.transform.origin
onready var body_initial_basis = body.transform.basis

onready var waist = $waist
onready var waist_initial_position = waist.transform.origin
onready var waist_initial_basis = waist.transform.basis

var current_wepon = null

var _level_visits= ","

var _stats = {
	"times_hit_by_bullet": 0,
	"times_fired_weapon": 0,
	"died": 0,
	}


signal die(object)

onready var dui_root = get_node("MeshInstance/dui_root")


func _ready():
	#spawn_point = get_node(spawn_point)
	damage_rng.randomize()
	health = initial_health
	$icons/death_icon.visible = false
	targetable = visible

	# connect to weapon
	current_wepon = $MeshInstance/weapon_mount.get_child(0)
	current_wepon.connect("fire", self, "_on_weapon_fire")


func _process(delta):
	# recoil on waist
	var recoil_v = Vector3(0.0, 0.0, recoil_time * -1.0 * recoil_magnitude).rotated(Vector3.UP, waist.get_rotation().y )
	waist.transform.origin = waist_initial_position + recoil_v
	body.transform.origin = body_initial_position + recoil_v

	# inspect dui
	if Input.is_action_just_pressed("inspect_digetic_ui"):
		dui_root.invoke_inventory_ring()
	
	if Input.is_action_just_released("inspect_digetic_ui"):
		dui_root.devoke_inventory_ring()

	if Input.is_action_just_pressed("inspect_weapons_ui"):
		dui_root.invoke_weapons_ring()
	
	if Input.is_action_just_released("inspect_weapons_ui"):
		dui_root.devoke_weapons_ring()
		
	if Input.is_action_just_pressed("ui_options"):
		dui_root.invoke_options_ring()

#	if Input.is_action_just_released("ui_options"):
#		dui_root.devoke_options_ring()


func set_active(new_value) -> void:
	active = new_value
	$CollisionShape.disabled = !new_value
	targetable = new_value
	$Controller.set_physics_process(new_value)
	$Controller.set_process(new_value)
	$Controller.set_process_input(new_value)
	$Controller.set_process_unhandled_input(new_value)
	if $Controller.weapon:
		$Controller.weapon.activated = false


func get_active():
	return active


func set_health(new_value) -> void:
	health = new_value
	hurt_meter.set_factor( 1.0 - health/initial_health )
	if health <= 0.0:
		die()


func die() -> void:
	$MeshInstance/hurt_meter.visible = false
	$icons/death_icon.visible = true
	set_active(false)
	yield(get_tree().create_timer(1.5), "timeout")
	visible = false
	#spawn_point.transport_player_to_spawn_point()
	emit_signal("die", self)
	_stats.died += 1

func respawn() -> void:
	set_health(initial_health)
	set_active(true)
	$MeshInstance/hurt_meter.visible = true
	$icons/death_icon.visible = false
	visible = true


func _on_weapon_fire(weapon) -> void:
	# recoil
	$recoil_animplayer.stop()
	$recoil_animplayer.play("recoil_time_animation", -1, 5.0)#3.5)#5.0) #7.5)
	# force
	$Controller.additional_force += -current_wepon.bullet_spawner.global_transform.basis.z.normalized() * weapon.fire_kickback
	_stats.times_fired_weapon += 1


func stop_movement() -> void:
	$Controller.movement = Vector3.ZERO


func bullet_hit(bullet, collision_info) -> void:
	if !get_active():
		return

	_stats.times_hit_by_bullet += 1
	
	# knockback
	$Controller.additional_force += bullet.global_transform.basis.z.normalized() * bullet.projectile_knockback * 0.5

	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	set_health( health - damage )


func add_level_visit(level_name, door_name) -> void :
	_level_visits += level_name + ":" + door_name + ","
	

func add_additional_force(force:Vector3) -> void:
	$Controller.additional_force += force



