extends CharacterBody3D

@export var initial_health : float = 100.0#1000.0
var health : float
@export var active: bool = true : set = toggle_active
@export var movement_speed: float = 7.5
@export var rush_speed: float = 300.0
@export var strafe_speed: float = 700.0
@export var acceleration: float = 3.0
@export var deaceleration: float = 5.0
@export var show_state_label: bool = true

var target : Node3D = null
var target_last_known_position = null
var can_see_target = false
var direction := Vector3.ZERO
var initial_movement_speed = movement_speed
var last_direction := Vector3.ZERO
var current_vertical_speed := Vector3.ZERO
var movement := Vector3.ZERO
var max_turn_rate := deg_to_rad(450.0)
var speed := Vector3.ZERO
var strafe_direction = 1.0 # 1.0 == right, -1.0 == left
var is_airborne : = false
var gravity := -40.0
var jump_acceleration := 3.0
var age := 0.0
var age_offset_rng = RandomNumberGenerator.new()
var age_offset := 0.0
var firing_noise_rng : FastNoiseLite = FastNoiseLite.new()#OpenSimplexNoise.new()
var accelerate = acceleration

@onready var label3d : Label3D = find_child("Label3D")

@onready var weapon = find_child("weapon_mount").get_child(0)
var attack_moves = ["rush", "evade", "strafe", "hold"]
var attack_move = "rush"
@onready var attack_move_timer = Timer.new()
var attack_move_rng = RandomNumberGenerator.new()

@onready var original_alert_icon_modulate = $alert_icon.get_modulate()

#const DO_TRAVEL_PATH = true
#var travel_path = null
#const travel_path_script = preload("res://data/scripts/travel_path_line.gd")

var noise : FastNoiseLite = FastNoiseLite.new()#OpenSimplexNoise.new()
var offset = 0.0

var damage_rng = RandomNumberGenerator.new()

const point_of_interest_scene = preload("res://data/enemies/PointOfInterest.tscn")
const enemy_corpse_scene = preload("res://data/enemies/EnemyCorpse.tscn")

const orb_pickup_scene = preload("res://data/pickups/orb_pickup.tscn")


@onready var hurt_meter = $MeshInstance3D/hurt_meter
@onready var fsm = $statemachine

signal notify_allies
@onready var ally_notification_recieve_timer = Timer.new()
var ally_notification_cooldown = 0.1#0.5
@onready var repeat_attack_notification_timer = Timer.new()
var repeat_attack_notification_frequency = 0.3
enum ally_notification {
	ENEMY_SPOTTED,
	NEW_SEARCH_POINT,
	LOCATION
}


func _ready():
	age_offset_rng.randomize()
	age_offset = age_offset_rng.randf_range(0.0, 100.0)
	damage_rng.randomize()
	noise.seed = randi()
	noise.fractal_octaves = 4
	noise.frequency = 0.01#period = 35.0
	offset = damage_rng.randf() * 100

	health = initial_health

	attack_move_rng.randomize()
	add_child(attack_move_timer)
	attack_move_timer.connect("timeout",Callable(self,"_on_attack_move_timer_timeout")) 
	attack_move_timer.set_one_shot(true)

	add_child(ally_notification_recieve_timer)
	ally_notification_recieve_timer.set_one_shot(true)

	add_child(repeat_attack_notification_timer)
	repeat_attack_notification_timer.set_wait_time( repeat_attack_notification_frequency )
	repeat_attack_notification_timer.connect("timeout",Callable(self,"_repeat_attack_notification_timeout"))

	weapon.visible = false
	
	firing_noise_rng.seed = randi()
	firing_noise_rng.fractal_octaves = 2
	firing_noise_rng.frequency = 0.5
	firing_noise_rng.fractal_gain = 0.8

#	if DO_TRAVEL_PATH and active:
#		travel_path = ImmediateMesh.new()
#		travel_path.set_script(travel_path_script)
#		travel_path.track_object_path = self.get_path()
#		travel_path.position_offset = Vector3(0.0, -0.5, 0.0)
#		get_node("/root/").add_child(travel_path)

	$alert_icon.visible = false
	target = null

	# wait a bit
	set_physics_process(false)
#	set_physics_process_internal(false)
	await get_tree().create_timer(0.35).timeout
	$CollisionShape3D.disabled = false
#	set_physics_process(true)
#	set_physics_process_internal(true)
	$hurtbox.connect("bullet_hit",Callable(self,"bullet_hit"))
	self.toggle_active(self.active)

	await get_tree().create_timer(3.0).timeout
	$CollisionShape3D.disabled = false
	$hurtbox/CollisionShape3D.disabled = false
	$vision_area/CollisionPolygon3D.disabled = true#false
	$sensable_area.monitoring = false#true
	$sensing_area.monitorable = false#true

	set_process(true)#false)#true)
	set_physics_process(true)#false)#true)

	label3d.visible = show_state_label


func bullet_hit(bullet, collision_info):
	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	health -= damage
	hurt_meter.set_factor( 1.0 - health/initial_health )

	_apply_bullet_knockback(bullet)

	$AudioStreamPlayer3D.set_volume_db( -8.0 )
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.65, 1.0)
	$AudioStreamPlayer3D.play()

	if fsm.state in ["idle", "search"]:
		set_new_poi_target(bullet.starting_position)
		fsm.set_state("search")

	# die
	if health <= 0.0:
		toggle_active(false)
		
#		if DO_TRAVEL_PATH and active:
#			travel_path.queue_free()

		if is_instance_valid(target) and (target as PointOfInterest):
			target.queue_free()
			target = null

		# corpse
		var corpse = enemy_corpse_scene.instantiate()
		corpse.transform = self.transform
		get_node("/root/").add_child(corpse)
		var impulse =(Vector3(0.0, 60.0, 0.0) + bullet.transform.basis.z * 35.0) * 0.2 #* 5.0 #25.0
		#var impulse_location = transform.basis.z * -.28 + Vector3(0.0, -0.55, 0.0)
		var impulse_location = transform.basis.z * -1.0 + Vector3(0.0, -1.0, 0.0)
		impulse_location *= 3.0
		#var impulse_location  = global_position + Vector3(0.0, -0.55, 0.0) + ( global_transform.basis.z * -3.5)
		corpse.apply_impulse( impulse, Vector3.ZERO )#impulse_location )#impulse_location, impulse)


		# torque impules is applied in a single step
		# in the corpse's _integrate_forces
#		var t_impulse = global_transform.basis.x * 250
#		pprint("t_impulse: %s"%t_impulse)
#		corpse.apply_torque_impulse( t_impulse )


		# drops
		for _i in range(1+randi()%12):
			
			var orb = orb_pickup_scene.instantiate()
			orb.transform.origin = self.transform.origin + Vector3(0.0, 0.55, 0.0)
			get_tree().get_root().add_child( orb )
			var oimp = Vector3(0.0, 250, 0.0) * 0.01#0.1
			orb.apply_central_impulse(oimp)



		$vision_raycast.stop()
		$vision_raycast.sight_line.queue_free()
		$vision_raycast.queue_free()
		repeat_attack_notification_timer.queue_free()
		# free weapon
		if $MeshInstance3D/weapon_mount.get_child_count() >0:
			$MeshInstance3D/weapon_mount.get_child(0).queue_free()
		queue_free()


func _apply_bullet_knockback(bullet):
	direction = Vector3(bullet.global_transform.basis.z).rotated(Vector3.UP, randf_range(-PI*0.3, PI*0.3))
	direction = direction.normalized()
	movement_speed = bullet.projectile_knockback
	rotate_y( [-1,1][randi()%2] * PI*0.25 )
	current_vertical_speed.y = 9.5#7.0


func apply_impulse(impulse : Vector3 = Vector3.ZERO) -> void:
	movement_speed = impulse.length()
	direction = impulse


# ------------------------------------------------------------------------------
# states
func _idle_enter():
	$alert_icon.visible = false
	weapon.set_activated(false)
	if is_instance_valid(target) and (target as PointOfInterest):
		target.queue_free()
	target = null
	weapon.visible = false
	label3d.text = "idle"

func _idle(delta) -> void:
	if $vision_raycast.can_see_target:
		weapon.visible = true
		fsm.set_state("attack")

	# wander about a bit
	var rot_y = noise.get_noise_1d( age * 25.0 + offset ) 
	rot_y = sign(rot_y) * Util.bias(abs(rot_y), 0.25) * 0.2
	rotate_y( rot_y )
	direction = global_transform.basis.z 
	var speedir_normoise = noise.get_noise_1d( age * 15.0 - offset )
	var spd = 0.0
	
	if speedir_normoise > 0.35:
		spd = Util.bias((speedir_normoise+1.0)/2.0, 0.2)
	elif speedir_normoise < -0.35:
		spd = -0.4 * Util.bias((abs(speedir_normoise)+1.0)/2.0, 0.2)
	movement_speed = -1 * spd * 7.5 * delta * 100.0

	flock_with_neighbours(delta)


func _attack_enter() -> void:
	$alert_icon.visible = true
	attack_move = "rush"
	attack_move_timer.start( attack_move_rng.randf_range(0.2, 0.5) )
	emit_communication_signal( ally_notification.ENEMY_SPOTTED)
	repeat_attack_notification_timer.start()
	weapon.visible = true
	label3d.text = "attack"


func _attack(delta) -> void:
	# see repeat_attack_notification_timer
	if !$vision_raycast.can_see_target:
		weapon.visible = false
		weapon.activated = false
		if target_last_known_position == null:
			fsm.set_state("idle")
		else:
			if is_instance_valid(target) and (target as PointOfInterest):
				target.queue_free()
				target = null
			var poi = point_of_interest_scene.instantiate()
			get_node("/root/").add_child(poi)
			poi.transform.origin = target_last_known_position * Vector3(1.0, 0.0, 1.0)
			self.target = poi
			fsm.set_state("search")
		return

	if is_instance_valid(target) and target:
		target_last_known_position = target.transform.origin

		rotate_toward_target(delta)

		var do_fire = firing_noise_rng.get_noise_1d(age + age_offset) > 0.0
		if do_fire:
			activate_weapon(delta)
		else:
			deactivate_wepon()

		# le fsm petite
		match attack_move:
			"rush":
				rush_toward_target(delta)
				label3d.text = "attack : rush"
			"hold":
				hold_to_target(delta)
				label3d.text = "attack : hold_to_target"
			"evade":
				evade_target(delta)
				label3d.text = "attack : evade_target"
			"strafe":
				strafe_target(delta)
				label3d.text = "attack : strafe_target"
		
		move_to_ideal_distance_to_target(delta)
	
	flock_with_neighbours(delta)


func _attack_exit() -> void:
	attack_move_timer.stop()
	ally_notification_recieve_timer.stop()
	repeat_attack_notification_timer.stop()


func _search_enter() -> void:
	weapon.set_activated(false)
	emit_communication_signal( ally_notification.NEW_SEARCH_POINT)
	weapon.visible = true
	label3d.text = "search"


func _search(delta):
	if $vision_raycast.can_see_target:
		weapon.visible = true
		fsm.set_state("attack")
	if is_instance_valid(target) and target:
		rotate_toward_target(delta)
		search_toward_target(delta)
		if (self.transform.origin - target.transform.origin).length() < 1.5:
			if is_instance_valid(target) and (target as PointOfInterest):
				target.queue_free()
				target = null
			fsm.set_state("idle")
	flock_with_neighbours(delta)


func _search_exit() -> void:
	ally_notification_recieve_timer.stop()


# /states
# ------------------------------------------------------------------------------


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


func move_to_ideal_distance_to_target(delta) -> void:
	# override direction and speed
	var distance : float = (global_transform.origin -
							target.global_transform.origin).length()
	if distance < 2.5:
		$alert_icon.modulate = Color(0.245132, 0.485675, 0.996094) *3.0
		direction = (target.global_transform.origin - global_transform.origin).normalized() * 2.0
		movement_speed = -2.0 * delta * rush_speed
	elif distance > 13.0:
		$alert_icon.modulate = Color(0.996094, 0.245132, 0.96676) *3.0
		direction = -1.0 *(target.global_transform.origin - global_transform.origin).normalized() * 2.0
		movement_speed = -1.5 * delta * rush_speed
	else:
		$alert_icon.modulate = original_alert_icon_modulate


func flock_with_neighbours(delta) -> void:
	var list = get_signal_connection_list("notify_allies")
#	signal connection list
#	pprint("flock_with_neighbours: %s"%str(list))
#	godot3:
#		{binds:[], flags:0, method:_on_ally_notification, signal:notify_allies, source:[CharacterBody3D:1894], target:[CharacterBody3D:1502]}
#	godot4:
#		{ "signal": CharacterBody3D(Enemy.gd)::[signal]notify_allies, "callable": CharacterBody3D(Enemy.gd)::_on_ally_notification, "flags": 0 }
	
	var forcev = Vector3.ZERO
	var min_distance = 4.5
	
	if list.size() > 0:
		var o = global_transform.origin
		#for i in range(list.size()):
		for i in range( min(list.size(), 4) ):
			#var to = list[i].target.global_transform.origin
			var to = list[i].callable.get_object().global_transform.origin
			var distance = (o-to).length()
			var dpow = clamp(1-(distance/min_distance), 0.0, 1.0)
			forcev += (to - o) * pow(dpow, 2.0) * 1.0

		var forcev_length = forcev.length()
		if forcev_length > 0.0:
			direction += forcev
			movement_speed += 10.0 * forcev_length * delta * rush_speed


func activate_weapon(delta) -> void:
	if within_aim_tolerance(weapon.aim_tolerance):
		if weapon.activated != true:
			pprint("activate_weapon")
			weapon.activated = true
	else:
		#pprint("de-activate_weapon (out of aim_tolerance)")
		#weapon.activated = false
		deactivate_wepon()


func deactivate_wepon() -> void:
	if weapon.activated == true:
		pprint("deactivate_weapon")
		weapon.activated = false


func hold_to_target(delta) -> void:
	direction = Vector3.ZERO
	movement_speed = 0.25


func rush_toward_target(delta) -> void:
	if is_instance_valid(target) and target and target.is_inside_tree():
		direction = global_transform.origin - target.global_transform.origin
		direction = direction.normalized() 
		movement_speed = -1.0 * delta * rush_speed


func search_toward_target(delta) -> void:
	if is_instance_valid(target) and target and target.is_inside_tree():
		direction = global_transform.origin - target.global_transform.origin
		direction = direction.normalized() 
		movement_speed = -1.0 * delta * (rush_speed * 2.0)


func evade_target(delta) -> void:
	if is_instance_valid(target) and target and target.is_inside_tree():	
		direction = global_transform.origin - target.global_transform.origin
		direction = direction.normalized() 
		movement_speed = 1.0 * delta * rush_speed * 0.65


func strafe_target(delta) -> void:
	direction = global_transform.basis.x.rotated(Vector3(0.0, 1.0, 0.0), strafe_direction * 0.3)
	direction = direction.normalized()
	movement_speed = strafe_direction * delta * strafe_speed


func rotate_toward_target(delta) -> void:
	if is_instance_valid(target) and target and target.is_inside_tree():
		var to = target.global_transform.origin
		var look = Vector3(to.x, global_transform.origin.y , to.z)
		var T=global_transform.looking_at(look, Vector3(0,1,0))
		global_transform.basis.x = lerp(global_transform.basis.x, T.basis.x, delta * max_turn_rate ).normalized()
		global_transform.basis.y = lerp(global_transform.basis.y, T.basis.y, delta * max_turn_rate ).normalized()
		global_transform.basis.z = lerp(global_transform.basis.z, T.basis.z, delta * max_turn_rate ).normalized()


func within_aim_tolerance( tolerance ) -> bool:
	if is_instance_valid(target) and target and target.is_inside_tree():
		var dir = -1.0 * global_transform.basis.z
		var dir_to_player = ((target.global_transform.origin - global_transform.origin) *
			Vector3(1.0, 0.0, 1.0)).normalized()
		return dir.dot( dir_to_player ) > (1.0 - tolerance)
	else:
		return false


func _process(delta):
	age += delta


func _physics_process(delta) -> void:
#	age += delta

	direction.y = 0.0
	var dir_norm : Vector3 = direction.normalized()
	last_direction = dir_norm
	var max_speed = movement_speed * dir_norm 
	accelerate = deaceleration
	
	if dir_norm.dot(speed) > 0.0:
		accelerate = acceleration

	direction = Vector3.ZERO

	speed = speed.lerp(max_speed, delta * accelerate)

	movement = speed

	if not is_on_floor():
		current_vertical_speed.y += gravity * delta * jump_acceleration
	else:
		current_vertical_speed.y = 0.0

	movement += current_vertical_speed
	set_velocity(movement)
	set_up_direction(Vector3.UP)
	###############################
	###############################
	###############################
	# https://www.reddit.com/r/godot/comments/zqibu3/move_and_slide_cause_bad_performance/
	###############################
	###############################
	###############################
	move_and_slide()
	###############################
	###############################
	###############################
	if is_on_floor():
		current_vertical_speed.y = 0.0
		is_airborne = false


func toggle_active(new_value) -> void:
	if new_value:
		self.visible = true
		$CollisionShape3D.disabled = false
		$hurtbox/CollisionShape3D.disabled = false
		$vision_area/CollisionPolygon3D.disabled = false
		$sensable_area.monitoring = true
		$sensing_area.monitorable = true
		set_process(true)
		set_process_internal(true)
		set_physics_process(true)
		set_physics_process_internal(true)
		#$vision_raycast.start()
	else:
		self.visible = false
		$CollisionShape3D.disabled = true
		$hurtbox/CollisionShape3D.disabled = true
		$vision_area/CollisionPolygon3D.disabled = true
		$sensable_area.monitoring = false
		$sensing_area.monitorable = false
		set_process(false)
		set_process_internal(false)
		set_physics_process(false)
		set_physics_process_internal(false)
		#$vision_raycast.stop()
	active = new_value


func _on_vision_area_body_entered(body) -> void:
	#pprint("_on_vision_area_body_entered %s"%body )
	if body.is_in_group("Player") and body.targetable:
		#pprint("  -> in group 'Player' and .targetable")
		if is_instance_valid(target) and (target as PointOfInterest):
			#pprint("  -> is_instance_valid(target) and (target as PointOfInterest)")
			target.queue_free()
			target=null
		target = body
		#pprint("  -> .target: %s"%self.target)
		$vision_raycast.target = body
		$vision_raycast.start()
		#await get_tree().create_timer(.05).timeout
		if $vision_raycast.can_see_target:
			$statemachine.set_state("attack")


func _on_vision_area_body_exited(body) -> void:
	# I think this gets called when self is
	# queue_free'd, and the vision area is removed
	if self.is_queued_for_deletion():
		if is_instance_valid(target) and (target as PointOfInterest):
			target.queue_free()
			target = null

	if body.is_in_group("Player") and !self.is_queued_for_deletion() and is_instance_valid(self):
		if target_last_known_position:
			set_new_poi_target(target_last_known_position)
			fsm.set_state("search")
		else:
			fsm.set_state("idle")
		$vision_raycast.target = null
		$vision_raycast.stop()
		deactivate_wepon()


func clear_poi_target() -> void:
		if is_instance_valid(target) and target:
			if is_instance_valid(target) and (target as PointOfInterest):
				target.queue_free()
				target = null


func set_new_poi_target(position: Vector3) -> void:
		clear_poi_target()
		var poi = point_of_interest_scene.instantiate()
		get_node("/root/").call_deferred("add_child", poi)
		#poi.transform.origin = position * Vector3(1.0, 0.0, 1.0)
		poi.transform.origin = position
		self.target = poi


# ------------------------------------------------------------------------------
# communication signals
func emit_communication_signal( notification_type:int):
	ally_notification_recieve_timer.start(ally_notification_cooldown)
	emit_signal("notify_allies", notification_type, self)


func _on_ally_notification( notification_type:int, emitter ) -> void:
	if ally_notification_recieve_timer.get_time_left() <= 0.0:
		if fsm.state != "attack":
			match notification_type:
				ally_notification.NEW_SEARCH_POINT:
					if is_instance_valid(emitter.target): #emitter.target:
						set_new_poi_target(emitter.target.transform.origin)
						if fsm.state != "search":
							fsm.set_state("search")
				ally_notification.ENEMY_SPOTTED:
					clear_poi_target()
					if is_instance_valid(emitter.target):#emitter.target:
						target = emitter.target
						if fsm.state != "search":
							fsm.set_state("search")


func _repeat_attack_notification_timeout():
	emit_communication_signal( ally_notification.ENEMY_SPOTTED)

# ------------------------------------------------------------------------------
# /communication signals

func _on_VisibilityNotifier_camera_entered(camera) -> void:
	# return to full processing
	#print(self.get_path(), " entered camera")
	pass


func _on_VisibilityNotifier_camera_exited(camera) -> void:
	# LOD process, animation and, movement
	#print(self.get_path(), " exited camera")
	pass
 

func pprint(thing) -> void:
	print("[enemy] %s"%str(thing))


