extends Camera3D

# https://gist.github.com/AndreaCatania/316fc412a7b478ca5226b5c17d963737

const speed = 0.75
const sensitivity = 0.002

var active := false
var motion: Vector3
var view_motion: Vector2
var gimbal_base: Transform3D
var gimbal_pitch: Transform3D
var gimbal_yaw: Transform3D


func is_active() -> bool:
	""" Return true when the fly camera is active. You can toggle the fly
	camera using the TAB keyboard. """
	return active


func _ready():
	#gimbal_base.origin = global_transform.origin
	#gimbal_base = global_transform
	# Unparent
	set_as_top_level(true)
	update_activation()


func update_mouse_relative( relative ) -> void:
	"""for getting passed mouse relative motion, eg through a SubViewport"""
	view_motion += relative


func _input(event):
	if event is InputEventMouseMotion:
		view_motion += event.relative
		print("view_motion IN FLY_CAMERA%s"%view_motion)
		get_viewport().set_input_as_handled()


	elif event is InputEventKey:
		if Input.is_action_just_pressed("toggle_fly_camera"):
			if event.pressed:
#				# Each click toggle.
				active = active == false
				update_activation()
				return

		if active == false:
			return

		var value: float = 0
		if event.pressed:
			value = 1

		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event.keycode == KEY_W:
			motion.z = value * -1.0
		elif event.keycode == KEY_S:
			motion.z = value
		elif event.keycode == KEY_A:
			motion.x = value * -1.0
		elif event.keycode == KEY_D:
			motion.x = value
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		print("motion: %s"%motion)
		get_viewport().set_input_as_handled()


func _process(delta):
	gimbal_base *= Transform3D(Basis(), global_transform.basis * (motion * speed))

	gimbal_yaw = gimbal_yaw.rotated(Vector3(0,1,0), view_motion.x * sensitivity * -1.0)
	gimbal_pitch = gimbal_pitch.rotated(Vector3(1,0,0), view_motion.y * sensitivity * -1.0)
	view_motion = Vector2()
	global_transform = gimbal_base * (gimbal_yaw * gimbal_pitch)



func update_activation():
	set_process(active)
	current = active
	if active == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
