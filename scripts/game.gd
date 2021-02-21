extends Node
# main game singleton

var minimum_size : Vector2 = Vector2(1024,600)#(960, 540)
var BORDERLESS_FULLSCREEN = false

var window_position := Vector2.ZERO
var fullscreen : = false

func _ready():
	print("game.dg autoload ready")
	var root = get_node("/root")
	root.connect("size_changed",self,"resize")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

	print("get_windows_size ",OS.get_window_size())
	print("get_screen_size ",OS.get_screen_size())

	# peep gamepads
	var gamepads = Input.get_connected_joypads()
	print("gamepads %s (%s)"%[gamepads, gamepads.size()])
	for i in range(gamepads.size()):
		print("  %s- \"%s\" %s"%[i, Input.get_joy_name(i), Input.get_joy_guid(i)])
		
	window_position = OS.get_window_position()

	if fullscreen:
		if not BORDERLESS_FULLSCREEN:
			OS.window_fullscreen = true
		else:
			OS.set_window_position(Vector2(0.0, 0.0))
			OS.set_window_size(OS.get_screen_size())
			OS.set_borderless_window(true)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_fullscreen"):
		_go_fullscreen()


func resize():
	var root = get_node("/root")
	var resolution = root.get_visible_rect() #root.get_rect()
	print("resolution: ", resolution)


func _go_fullscreen():
	if not BORDERLESS_FULLSCREEN:
		OS.window_fullscreen = !OS.window_fullscreen
		fullscreen = !fullscreen
		if not OS.window_fullscreen:
			OS.set_window_size(minimum_size)
			OS.set_borderless_window(false)
		else:
			OS.set_window_position(window_position)
	else:
		fullscreen = !fullscreen
		if fullscreen:
			OS.set_window_size(OS.get_screen_size())
			OS.set_borderless_window(true)
			OS.set_window_position(Vector2(0.0, 0.0))
		else:
			OS.set_borderless_window(false)
			OS.set_window_size(minimum_size)
			OS.set_window_position(window_position)
