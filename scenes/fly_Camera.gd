extends Camera3D

# https://gist.github.com/AndreaCatania/316fc412a7b478ca5226b5c17d963737

const normal_speed = 0.15
const fast_speed = 0.75
const rotate_sensitivity = 0.002
const pan_sensitivity = 0.02

var speed = normal_speed

var active := false
var panning: bool
var dollying: bool
var motion: Vector3
var view_motion: Vector2
var view_pan_motion: Vector2
var view_dolly_motion: Vector2
var gimbal_base: Transform3D
var gimbal_pitch: Transform3D
var gimbal_yaw: Transform3D


func is_active() -> bool:
	""" Return true when the fly camera is active. You can toggle the fly
	camera using the TAB keyboard. """
	return active


func _ready():
	gimbal_base.origin = global_transform.origin
	#gimbal_base = global_transform
	# Unparent
	set_as_top_level(true)
	update_activation()


func _unhandled_input(event):
	if active == false:
			return

	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:

#		if event is InputEventMouseButton and event.is_pressed():
#			print("fly_camera: mouse button DOWN index %s"%event.button_index)

		if event is InputEventMouseButton and event.is_pressed():
			# middle mouse pan
			if event.button_index == 3:
				panning = true
			# right mouse dolly
			if event.button_index == 2 :
				dollying = true
		elif event is InputEventMouseButton and event.is_pressed() == false:
			if event.button_index == 3:
				panning = false
			if event.button_index == 2 :
				dollying = false

		if event is InputEventMouseMotion:
			if not panning and not dollying:
				view_motion += event.relative
			elif panning:
				view_pan_motion += event.relative
			elif dollying:
				view_dolly_motion += event.relative


func _input(event):
	if event is InputEventMouseMotion:
#		view_motion += event.relative
#		print("view_motion IN FLY_CAMERA%s"%view_motion)
#		get_viewport().set_input_as_handled()
		pass

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

		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		if event.keycode == KEY_SHIFT:
			if event.pressed:
				speed = fast_speed
			else:
				speed = normal_speed

		if event.keycode == KEY_W:
			motion.z = value * -1.0
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_S:
			motion.z = value
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_A:
			motion.x = value * -1.0
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_D:
			motion.x = value
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E: # raise
			motion.y = value
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_Q: # lower
			motion.y = value * -1.0
			get_viewport().set_input_as_handled()
		else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pass
		#get_viewport().set_input_as_handled()


func _process(delta):
	gimbal_base *= Transform3D(Basis(), \
								global_transform.basis * (motion * speed) +
								global_transform.basis * (Vector3(view_pan_motion.x, -view_pan_motion.y, view_dolly_motion.y) * pan_sensitivity) )

	gimbal_yaw = gimbal_yaw.rotated(Vector3(0,1,0), view_motion.x * rotate_sensitivity * -1.0)
	gimbal_pitch = gimbal_pitch.rotated(Vector3(1,0,0), view_motion.y * rotate_sensitivity * -1.0)
	view_motion = Vector2()
	view_pan_motion = Vector2()
	view_dolly_motion = Vector2()
	global_transform = gimbal_base * (gimbal_yaw * gimbal_pitch)



func update_activation():
	set_process(active)
	current = active
#	if active == false:
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
