extends Spatial
# player controller

export(NodePath) var PlayerPath  = ""
export(NodePath) var CameraPath  = ""
export(NodePath) var CameraRootPath  = ""
export(NodePath) var MeshInstancePath  = ""
export(float) var movement_speed = 15.0
export(float) var acceleration = 3.0
export(float) var deaceleration = 5.0
export(float) var max_jump = 12.0
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

var camera_lookahead_factor = 0.0
var camera_lookahead_direction : Vector3 # keep normalised
var camera_lookahead_direction_actual : Vector3
var camera_lookahead_factor_actual = 0.0
var direction := Vector3.ZERO
var last_direction := Vector3.ZERO
var camera_rotation
var gravity := -10.0
var accelerate = acceleration
var movement := Vector3.ZERO
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

enum ROTATION_INPUT{MOUSE, JOYSTICK, MOVE_DIR}

func _ready():
	# avoid taking any input that is dribbled over from before the node is ready
	set_process(false)
	yield(get_tree().create_timer(0.25), "timeout")
	set_process(true)

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
	# shoot
	if Input.is_action_just_pressed("shoot"):
		weapon.activated = true
	
	if Input.is_action_just_released("shoot"):
		weapon.activated = false
		
	# jump
	if (Input.is_action_pressed("jump")) and not is_airborne:
		current_vertical_speed = Vector3(0.0, max_jump, 0.0)
		is_airborne = true


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

	# dolly
	actual_zoom = lerp(actual_zoom, zoom_factor, dt * zoom_speed)
	camera_boom.translation = Vector3(0.0, 0.0, actual_zoom)

	# lookahead
	camera_lookahead_factor_actual = lerp(camera_lookahead_factor_actual, camera_lookahead_factor, dt * 3.0 )
	camera_lookahead_direction_actual = camera_lookahead_direction_actual.linear_interpolate(camera_lookahead_direction, dt * 1.5)
	camera_root.transform.origin = camera_lookahead_direction_actual * camera_lookahead_factor_actual * 7.5

