extends KinematicBody

export var initial_health : float = 1000.0
var health : float
export(bool) var active = true setget toggle_active
export(float) var movement_speed = 7.5
export(float) var rush_speed = 200.0
export(float) var strafe_speed = 500.0
export(float) var acceleration = 3.0
export(float) var deaceleration = 5.0

var target : Spatial = null
var can_see_target = false
var direction := Vector3.ZERO
var initial_movement_speed = movement_speed
var last_direction := Vector3.ZERO
var current_vertical_speed := Vector3.ZERO
var movement := Vector3.ZERO
var max_turn_rate := deg2rad(450.0)
var speed := Vector3.ZERO
var strafe_direction = 1.0 # 1.0 == right, -1.0 == left
var is_airborne : = false
var gravity := -10.0
var jump_acceleration := 3.0
var age := 0.0
var age_offset_rng = RandomNumberGenerator.new()
var age_offset := 0.0
var firing_noise_rng = OpenSimplexNoise.new()
var accelerate = acceleration

onready var weapon = find_node("weapon_mount").get_child(0)
var attack_moves = ["rush", "evade", "strafe", "hold"]
var attack_move = "rush"
onready var attack_move_timer = Timer.new()
var attack_move_rng = RandomNumberGenerator.new()

onready var original_alert_icon_modulate = $alert_icon.get_modulate()

const DO_TRAVEL_PATH = true
var travel_path = null
const travel_path_script = preload("res://data/scripts/travel_path_line.gd")

var noise = OpenSimplexNoise.new()
var offset = 0.0

var damage_rng = RandomNumberGenerator.new()

onready var hurt_meter = $MeshInstance/hurt_meter
onready var fsm = $statemachine


func _ready():
	age_offset_rng.randomize()
	age_offset = age_offset_rng.randf_range(0.0, 100.0)
	damage_rng.randomize()
	$hurtbox.connect("bullet_hit", self, "bullet_hit")
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 35.0
	offset = damage_rng.randf() * 100

	health = initial_health

	attack_move_rng.randomize()
	add_child(attack_move_timer)
	attack_move_timer.connect("timeout",self,"_on_attack_move_timer_timeout") 
	attack_move_timer.set_one_shot(true)

	weapon.visible = false
	
	firing_noise_rng.seed = randi()
	firing_noise_rng.octaves = 2
	firing_noise_rng.period = 0.5
	firing_noise_rng.persistence = 0.8

	if DO_TRAVEL_PATH and active:
		travel_path = ImmediateGeometry.new()
		travel_path.set_script(travel_path_script)
		travel_path.track_object_path = self.get_path()
		travel_path.position_offset = Vector3(0.0, -0.5, 0.0)
		get_node("/root/").add_child(travel_path)

	$alert_icon.visible = false


func bullet_hit(bullet):
	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	health -= damage
	hurt_meter.set_factor( 1.0 - health/initial_health )
	print("  bullet damage %s, health %s"%[damage, health])

	if health <= 0.0:
		if DO_TRAVEL_PATH:
			travel_path.queue_free()
		queue_free()


func _idle_enter():
	$alert_icon.visible = false
	weapon.set_activated(false)


func _idle(delta) -> void:
	if $vision_raycast.can_see_target:
		weapon.visible = true
		fsm.set_state("attack")

	# wander about a bit
	var rot_y = noise.get_noise_1d( age * 25.0 + offset ) 
	rot_y = sign(rot_y) * Util.bias(abs(rot_y), 0.25) * 0.2
	rotate_y( rot_y )
	direction = global_transform.basis.z 
	var speed_noise = noise.get_noise_1d( age * 15.0 - offset )
	var spd = 0.0
	
	if speed_noise > 0.35:
		spd = Util.bias((speed_noise+1.0)/2.0, 0.2)
	elif speed_noise < -0.35:
		spd = -0.4 * Util.bias((abs(speed_noise)+1.0)/2.0, 0.2)
	movement_speed = -1 * spd * 7.5 * delta * 100.0


# ------------------------------------------------------------------------------
# attack move pattern experiment


func _attack_enter() -> void:
	#print("++ attack enter ++")
	$alert_icon.visible = true
	attack_move = "rush"
	attack_move_timer.start( attack_move_rng.randf_range(0.2, 0.5) )


func _attack(delta) -> void:

	if !$vision_raycast.can_see_target:
		weapon.visible = false
		weapon.activated = false
		fsm.set_state("idle")
		return

	rotate_toward_target(delta)

	var do_fire = firing_noise_rng.get_noise_1d(age + age_offset) > 0.0
	if do_fire:
		activate_weapon(delta)
	else:
		deactivate_wepon()

	match attack_move:
		"rush":
			rush_toward_target(delta)
		"hold":
			hold_to_target(delta)
		"evade":
			evade_target(delta)
		"strafe":
			strafe_target(delta)
	
	move_to_ideal_distance(delta)


func _attack_exit() -> void:
	attack_move_timer.stop()


func _on_attack_move_timer_timeout() -> void:
	# timeout timer
	# - reset timer to random time
	# - switch attack_move to random from attack_moves
	attack_move = attack_moves[attack_move_rng.randi_range(0, attack_moves.size()-1)]
	match attack_move:
		"rush":
			attack_move_timer.start(
				attack_move_rng.randf_range(0.2, 0.4)
				)
		"hold":
			attack_move_timer.start(
				attack_move_rng.randf_range(0.05, 0.15)
				)
		"evade":
			attack_move_timer.start(
				attack_move_rng.randf_range(0.15, 0.65)
				)
		"strafe":
			strafe_direction = pow(-1, randi() % 2)
			attack_move_timer.start(
				attack_move_rng.randf_range(0.55, 1.5)
				)


# ------------------------------------------------------------------------------

func move_to_ideal_distance(delta) -> void:
	# override direction and speed
	var distance : float = (global_transform.origin -
							target.global_transform.origin).length()
	if distance < 2.5:
		$alert_icon.modulate = Color(0.245132, 0.485675, 0.996094) *3.0
		direction = (target.global_transform.origin - global_transform.origin).normalized() * 2.0
		#direction = 1.0 * direction.normalized()
		movement_speed = -2.0 * delta * rush_speed
	elif distance > 13.0:
		$alert_icon.modulate = Color(0.996094, 0.245132, 0.96676) *3.0
		direction = -1.0 *(target.global_transform.origin - global_transform.origin).normalized() * 2.0
		#direction = -1.0 * direction.normalized()
		movement_speed = -1.5 * delta * rush_speed
	else:
		$alert_icon.modulate = original_alert_icon_modulate


func activate_weapon(delta) -> void:
	if within_aim_tolerance(weapon.aim_tolerance):
		weapon.activated = true
	else:
		weapon.activated = false


func deactivate_wepon() -> void:
	weapon.activated = false


func hold_to_target(delta) -> void:
	direction = Vector3.ZERO
	movement_speed = 0.25


func rush_toward_target(delta) -> void:
	direction = global_transform.origin - target.global_transform.origin
	direction = direction.normalized() 
	movement_speed = -1.0 * delta * rush_speed


func evade_target(delta) -> void:
	direction = global_transform.origin - target.global_transform.origin
	direction = direction.normalized() 
	movement_speed = 1.0 * delta * rush_speed * 0.65


func strafe_target(delta) -> void:
	direction = global_transform.basis.x.rotated(Vector3(0.0, 1.0, 0.0), strafe_direction * 0.3)
	direction = direction.normalized()
	movement_speed = strafe_direction * delta * strafe_speed


func rotate_toward_target(delta) -> void:
	var to = target.global_transform.origin
	var look = Vector3(to.x, global_transform.origin.y , to.z)
	var T=global_transform.looking_at(look, Vector3(0,1,0))
	global_transform.basis.x = lerp(global_transform.basis.x, T.basis.x, delta * max_turn_rate ).normalized()
	global_transform.basis.y = lerp(global_transform.basis.y, T.basis.y, delta * max_turn_rate ).normalized()
	global_transform.basis.z = lerp(global_transform.basis.z, T.basis.z, delta * max_turn_rate ).normalized()


func within_aim_tolerance( tolerance ) -> bool:
	var dir = -1.0 * global_transform.basis.z
	var dir_to_player = ((target.global_transform.origin - global_transform.origin) *
		Vector3(1.0, 0.0, 1.0)).normalized()
	return dir.dot( dir_to_player ) > (1.0 - tolerance)
	

func _physics_process(delta):
	age += delta

	direction.y = 0.0
	last_direction = direction.normalized()
	var max_speed = movement_speed * direction.normalized()
	accelerate = deaceleration
	if direction.dot(speed) > 0.0:
		accelerate = acceleration
	direction = Vector3.ZERO
	speed = speed.linear_interpolate(max_speed, delta * accelerate)
	movement = transform.basis * speed
	movement = speed

	current_vertical_speed.y += gravity * delta * jump_acceleration
	movement += current_vertical_speed
	move_and_slide(movement, Vector3.UP)
	if is_on_floor():
		current_vertical_speed.y = 0.0
		is_airborne = false


func toggle_active(new_value):
	print(self, " active ", new_value)
	if new_value:
		self.visible = true
		$CollisionShape.disabled = false
		$hurtbox/CollisionShape.disabled = false
		$vision_area/CollisionPolygon.disabled = false
	else:
		self.visible = false
		$CollisionShape.disabled = true
		$hurtbox/CollisionShape.disabled = true
		$vision_area/CollisionPolygon.disabled = true
	active = new_value


func _on_vision_area_body_entered(body):
	if body.is_in_group("Player") and body.targetable:
		weapon.visible = true
		target = body
		$vision_raycast.target = body
		$vision_raycast.start()
		yield(get_tree().create_timer(.05), "timeout")
		if $vision_raycast.can_see_target:
			$statemachine.set_state("attack")


func _on_vision_area_body_exited(body):
	if body.is_in_group("Player"):
		weapon.visible = false
		target = null
		$statemachine.set_state("idle")
		$vision_raycast.target = null
		$vision_raycast.stop()



func _on_VisibilityNotifier_camera_entered(camera):
	# return to full processing
	#print(self.get_path(), " entered camera")
	pass



func _on_VisibilityNotifier_camera_exited(camera):
	# LOD process, animation and, movement
	#print(self.get_path(), " exited camera")
	pass
