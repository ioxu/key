extends Spatial
# player controller

const harmonic_motion_lib = preload("res://data/scripts/harmonic_motion.gd")

export(NodePath) var PlayerPath  = ""
export(NodePath) var CameraPath  = ""
export(NodePath) var CameraRootPath  = ""
export(NodePath) var MeshInstancePath  = ""
export(float) var movement_speed = 15.0
export(float) var acceleration = 3.0
export(float) var deaceleration = 6.5#5.0
export(float) var max_jump = 30.0#12.0
export(float) var camera_rotation_speed = 3.0
export(float) var max_zoom = 8.0 #0.5
export(float) var min_zoom = 30.0 #1.5
export(float) var zoom_speed = 4.0

onready var player : KinematicBody = get_node(PlayerPath)
onready var camera : Camera = get_node(CameraPath)
onready var camera_root = get_node(CameraRootPath)
onready var camera_base = get_node(CameraRootPath).find_node("camera_base") # InnerGimbal
onready var camera_boom = camera_root.find_node("camera_boom")
onready var meshinstance = get_node(MeshInstancePath)
onready var weapon = player.find_node("weapon_mount").get_child(0)
onready var raycast : RayCast = player.get_node("RayCast")


# movement and legs and animation and things
var last_waist_ry := 0.0


onready var waist = get_node("../waist")
onready var waist_initial_position = waist.transform.origin
onready var waist_initial_basis = waist.transform.basis
var waist_rotation_harmonic_motion = harmonic_motion_lib.new()
var waist_rotation_harmonic_damping := 0.85
var waist_rotation_harmonic_frequency := 7.5
var waist_rotation_harmonic_parms
var _w_rot_hv = 0.0
var waist_rotation_knee_roll = -10.0

onready var toe_1_node = get_node("../toe_1_position")
onready var toe_2_node = get_node("../toe_2_position")
onready var toe_3_node = get_node("../toe_3_position")
onready var toe_4_node = get_node("../toe_4_position")
onready var toe_1_initial_position = toe_1_node.transform.origin
onready var toe_2_initial_position = toe_2_node.transform.origin
onready var toe_3_initial_position = toe_3_node.transform.origin
onready var toe_4_initial_position = toe_4_node.transform.origin

onready var leg_1_node = get_node("../leg_1")
onready var leg_2_node = get_node("../leg_2")
onready var leg_3_node = get_node("../leg_3")
onready var leg_4_node = get_node("../leg_4")


# camera lookahead
enum CAMERA_LOOKAHEAD_INTERP_MODE {linear, harmonic}
export(CAMERA_LOOKAHEAD_INTERP_MODE) var camera_interpolation_mode = CAMERA_LOOKAHEAD_INTERP_MODE.harmonic
export(float) var camera_lookahead_harmonic_damping := 0.85 setget set_camera_lookahead_harmonic_spring_damping
export(float) var camera_lookahead_harmonic_angular_frequency := 2.5 setget set_camera_lookahead_harmonic_spring_frequency
var c_la_hv = Vector3.ZERO # camera lookahead harmonic velocity
var camera_lookahead_harmonic_motion = harmonic_motion_lib.new()
var camera_lookahead_harmonic_parms

var camera_lookahead_factor = 0.0
var camera_lookahead_direction : Vector3 # keep normalised
var camera_lookahead_direction_actual : Vector3
var camera_lookahead_factor_actual = 0.0
const CAMERA_LOOKAHEAD_DISTANCE = 5.5#7.5


# character motion
var direction := Vector3.ZERO
var last_direction := Vector3.ZERO
var camera_rotation
var gravity := -40#-10.0
var accelerate = acceleration
var movement := Vector3.ZERO
var additional_force := Vector3.ZERO
var actual_mesh_rot_y := 0.0
var rotation_speed := 0.05
var zoom_factor : float = min_zoom
var actual_zoom : float = min_zoom
var zoom_step := 0.4
var speed := Vector3.ZERO
var current_vertical_speed := Vector3.ZERO
var jump_acceleration := 3.0
var is_airborne = false
var joystick_move_deadzone := 0.1
var joystick_look_deadzone := 0.45
var mouse_deadzone := 20

var global_time := 0.0

enum ROTATION_INPUT{MOUSE, JOYSTICK, MOVE_DIR}


func _ready():
	# avoid taking any input that is dribbled over from before the node is ready
	set_process(false)
	yield(get_tree().create_timer(0.25), "timeout")
	set_process(true)

	if camera_interpolation_mode == CAMERA_LOOKAHEAD_INTERP_MODE.harmonic:
		camera_lookahead_harmonic_parms = camera_lookahead_harmonic_motion.CalcDampedSpringMotionParams( camera_lookahead_harmonic_damping,
																	camera_lookahead_harmonic_angular_frequency )

	waist_rotation_harmonic_parms = waist_rotation_harmonic_motion.CalcDampedSpringMotionParams( 
		waist_rotation_harmonic_damping,
		waist_rotation_harmonic_frequency
	)


func _unhandled_input(event):
	# mesh rotaion with joystick
	if event is InputEventJoypadMotion:
		var horizontal = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		var vertical = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
		if look_joy_outside_deadzone():
			var v = Vector2(horizontal,vertical)
			rotate_mesh( v, ROTATION_INPUT.JOYSTICK )
			camera_lookahead_direction = get_camera_lookahead_direction(v, ROTATION_INPUT.JOYSTICK)
			camera_lookahead_factor = v.length()
		else:
			camera_lookahead_factor = 0.0
			rotate_mesh( speed, ROTATION_INPUT.MOVE_DIR )

	# mesh rotation with mouse motion
	elif event is InputEventMouseMotion and not look_joy_outside_deadzone():
		if magnitude(event.get_speed()) > mouse_deadzone:
			rotate_mesh(event, ROTATION_INPUT.MOUSE)
		else:
			rotate_mesh(speed, ROTATION_INPUT.MOVE_DIR)

	# mesh rotation with mouse left click
	elif event is InputEventMouseButton and event.get_button_index() == BUTTON_LEFT:
		rotate_mesh(event, ROTATION_INPUT.MOUSE)

	# zoom
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				zoom_factor -= zoom_step
			BUTTON_WHEEL_DOWN:
				zoom_factor += zoom_step
		zoom_factor = clamp(zoom_factor, max_zoom, min_zoom)


func look_joy_outside_deadzone():
		var horizontal = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		var vertical = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
		var look_length = Vector2(horizontal, vertical).length()
		return look_length > joystick_look_deadzone


func get_move_direction_length():
	var horizontal = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	return Vector2(horizontal, vertical).length()


func get_camera_lookahead_direction(event_data : Vector2, input_method):
	match input_method:
		ROTATION_INPUT.JOYSTICK:
			var av = event_data.normalized()
			var rot = atan2(av.y,av.x)
			rot += camera_base.get_rotation().y 
			return Vector3(1.0,0.0,0.0).rotated( Vector3.UP, rot )


func set_camera_lookahead_harmonic_spring_damping( damp: float = 0.0 ):
	camera_lookahead_harmonic_damping = damp
	_upadate_camera_lookahead_harmonic_motion_params()


func set_camera_lookahead_harmonic_spring_frequency( freq: float = 0.0 ):
	camera_lookahead_harmonic_angular_frequency = freq
	_upadate_camera_lookahead_harmonic_motion_params()


func _upadate_camera_lookahead_harmonic_motion_params() -> void:
	camera_lookahead_harmonic_parms = camera_lookahead_harmonic_motion.CalcDampedSpringMotionParams( camera_lookahead_harmonic_damping,
																							camera_lookahead_harmonic_angular_frequency )


func rotate_mesh( event_data, input_method ):
	match input_method:
		ROTATION_INPUT.JOYSTICK:
			var av = event_data.normalized()
			var rot = atan2(av.y,av.x)*180/PI
			rot += camera_base.get_rotation_degrees().y 
			rot += 90.0
			meshinstance.set_rotation_degrees(Vector3(-90,rot,0))
		ROTATION_INPUT.MOUSE:
			var ray_length := 600.0
			var from = camera.project_ray_origin( event_data.position ) - player.transform.origin
			var to = from + camera.project_ray_normal(event_data.position) * ray_length
			raycast.translation = from
			raycast.cast_to = to
			raycast.force_raycast_update()
			var collision_point = raycast.get_collision_point()
			meshinstance.look_at(collision_point, Vector3.UP)
			var rotation_degree = meshinstance.get_rotation_degrees().y
			meshinstance.set_rotation_degrees(Vector3(-90.0, rotation_degree + 180.0, 0.0))
		ROTATION_INPUT.MOVE_DIR:
			if magnitude(event_data) > 0.0 and last_direction.dot(event_data.normalized()) !=0:
				var angle = atan2(event_data.x, event_data.z)
				var char_rot = meshinstance.get_rotation()
				var rot_y =  angle - char_rot.y
				meshinstance.rotate_y( rot_y )


func magnitude(vector):
	if typeof(vector) == typeof(Vector2()):
		return sqrt(vector.x*vector.x + vector.y*vector.y)
	elif typeof(vector) == typeof(Vector3()):
		return sqrt(vector.x*vector.x + vector.z*vector.z)


func _process(dt):
	global_time += dt
	
	# shoot
	if Input.is_action_just_pressed("shoot"):
		weapon.activated = true
	
	if Input.is_action_just_released("shoot"):
		weapon.activated = false
		
	# jump
	if (Input.is_action_pressed("jump")) and not is_airborne:
		current_vertical_speed = Vector3(0.0, max_jump, 0.0)
		is_airborne = true


	############################################################################
	############################################################################
	# IK LEGS HIPS AND TOES

	# waist and toes rotating in a circle
#	waist.transform.basis = waist_initial_basis.rotated( Vector3.UP, global_time * 5 )
#	toe_1_node.transform.origin = toe_1_initial_position.rotated( Vector3.UP, global_time * 5  )
#	toe_2_node.transform.origin = toe_2_initial_position.rotated( Vector3.UP, global_time * 5 )
#	toe_3_node.transform.origin = toe_3_initial_position.rotated( Vector3.UP, global_time * 5 )
#	toe_4_node.transform.origin = toe_4_initial_position.rotated( Vector3.UP, global_time * 5 )

	# waist and toes following look-at direction
	#var lerp_a :=  lerp_angle(last_waist_ry, meshinstance.get_rotation().y, 0.06)#0.075)
	
	#var curr_ry := 0.0
	
	#curr_ry = lerp_a
	
	var wo = waist_rotation_harmonic_motion.calculate(
						waist.get_rotation().y,
						_w_rot_hv,
						lerp_angle(waist.get_rotation().y, meshinstance.get_rotation().y, 1.0),
						waist_rotation_harmonic_parms
		)

	_w_rot_hv = wo[1]

	var curr_ry = wo[0]
	
	waist.transform.basis = waist_initial_basis.rotated( Vector3.UP, curr_ry )

	var waist_ry_dt = last_waist_ry - curr_ry
	last_waist_ry = curr_ry
	
	# TOES LEADING MOVEMENT ####################################################
#	var movement_v = movement * + 0.04
#	toe_1_node.transform.origin = toe_1_initial_position.rotated( Vector3.UP, curr_ry ) + movement_v
#	toe_2_node.transform.origin = toe_2_initial_position.rotated( Vector3.UP, curr_ry ) + movement_v
#	toe_3_node.transform.origin = toe_3_initial_position.rotated( Vector3.UP, curr_ry ) + movement_v
#	toe_4_node.transform.origin = toe_4_initial_position.rotated( Vector3.UP, curr_ry ) + movement_v

	# TOES SPREADING OUT FROM MOVEMENT #########################################
	# length that leg is spread from body, maybe measure in worldspace and soft-limit?
	# so that speed isn't taken into account. Speed could scale but toes would only be some constant
	# factor away from body ...
	var movement_v = movement * + 0.06 
	
	var movement_v_norm = movement_v.normalized()
	
	#var toe_mv_dot_blend = 1.0#0.75 ## !!!!!!!!!!!!!!!! at 1.0 it is completely redundant. Consider removing Util.remap_clamp quotient
	var t1p = toe_1_initial_position.rotated( Vector3.UP, curr_ry )
	var d1 = t1p.normalized().dot( movement_v_norm )
	#t1p += sign(d1) * movement_v * Util.remap_clamp( abs(d1), 0.0, toe_mv_dot_blend, 0.0, 1.0 )
	t1p += sign(d1) * movement_v * abs(d1)
	
	var t2p = toe_2_initial_position.rotated( Vector3.UP, curr_ry )
	var d2 = t2p.normalized().dot( movement_v_norm )
	#t2p += sign(d2) * movement_v * Util.remap_clamp( abs(d2), 0.0, toe_mv_dot_blend, 0.0, 1.0)
	t2p += sign(d2) * movement_v * abs(d2)
	
	var t3p = toe_3_initial_position.rotated( Vector3.UP, curr_ry )
	var d3 = t3p.normalized().dot( movement_v_norm )
	#t3p += sign(d3) * movement_v * Util.remap_clamp( abs(d3), 0.0, toe_mv_dot_blend, 0.0, 1.0 )
	t3p += sign(d3) * movement_v * abs(d3)
	
	var t4p = toe_4_initial_position.rotated( Vector3.UP, curr_ry )
	var d4 = t4p.normalized().dot( movement_v_norm )
	#t4p += sign(d4) * movement_v * Util.remap_clamp( abs(d4), 0.0, toe_mv_dot_blend, 0.0, 1.0 )
	t4p += sign(d4) * movement_v * abs(d4)
	
	toe_1_node.transform.origin = t1p
	toe_2_node.transform.origin = t2p
	toe_3_node.transform.origin = t3p
	toe_4_node.transform.origin = t4p

	#prints("WAIST DT", waist_ry_dt)
	# bend knees on waist rotation
	leg_1_node.roll = waist_ry_dt * waist_rotation_knee_roll
	leg_2_node.roll = waist_ry_dt * waist_rotation_knee_roll
	leg_3_node.roll = waist_ry_dt * waist_rotation_knee_roll
	leg_4_node.roll = waist_ry_dt * waist_rotation_knee_roll

	# /IK LEGS HIPS AND TOES
	############################################################################
	############################################################################


func _physics_process(dt):
	# orbit camera
	camera_rotation = camera_rotation_speed * dt
	if Input.is_action_pressed("camera_rotate_left"):
		camera_base.rotate(Vector3.UP, camera_rotation)
	if Input.is_action_pressed("camera_rotate_right"):
		camera_base.rotate(Vector3.UP, -camera_rotation)

	# movement
	var camera_transform = camera.get_global_transform()
	
	if Input.is_action_pressed("move_up"):
		direction += -camera_transform.basis[2]
	if Input.is_action_pressed("move_down"):
		direction += camera_transform.basis[2]
	if Input.is_action_pressed("move_left"):
		direction += -camera_transform.basis[0]
	if Input.is_action_pressed("move_right"):
		direction += camera_transform.basis[0]
	direction.y = 0.0
	last_direction = direction.normalized()
	var max_speed = movement_speed * direction.normalized() * get_move_direction_length()
	max_speed += additional_force
	accelerate = deaceleration
	if direction.dot(speed) > 0.0:
		accelerate = acceleration
	direction = Vector3.ZERO
	speed = speed.linear_interpolate(max_speed, dt * accelerate)
	movement = speed
	current_vertical_speed.y += gravity * dt * jump_acceleration
	movement += current_vertical_speed
	
	
	player.move_and_slide(movement, Vector3.UP)
	if player.is_on_floor():
		current_vertical_speed.y = 0.0
		is_airborne = false

	# camera dolly
	actual_zoom = lerp(actual_zoom, zoom_factor, dt * zoom_speed)
	camera_boom.translation = Vector3(0.0, 0.0, actual_zoom)

	# camera lookahead
	var co = Vector3.ZERO
	if camera_interpolation_mode == CAMERA_LOOKAHEAD_INTERP_MODE.linear:
		camera_lookahead_factor_actual = lerp(camera_lookahead_factor_actual, camera_lookahead_factor, dt * 3.0 )
		camera_lookahead_direction_actual = camera_lookahead_direction_actual.linear_interpolate(camera_lookahead_direction, dt * 1.5)
		co = camera_lookahead_direction_actual * camera_lookahead_factor_actual * CAMERA_LOOKAHEAD_DISTANCE
	elif camera_interpolation_mode == CAMERA_LOOKAHEAD_INTERP_MODE.harmonic:
		var target = camera_lookahead_direction * camera_lookahead_factor * CAMERA_LOOKAHEAD_DISTANCE
		co = camera_lookahead_harmonic_motion.calculate_v3( camera_root.transform.origin, c_la_hv, target, camera_lookahead_harmonic_parms )
		c_la_hv = co[1]
		co = co[0]

	camera_root.transform.origin = co


	additional_force = Vector3.ZERO

