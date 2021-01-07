extends Node
# main game singleton

var minimum_size : Vector2 = Vector2(1024,600)#(960, 540)

func _ready():
	print("game.dg autoload ready")
	var root = get_node("/root")
	root.connect("size_changed",self,"resize")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

	# peep gamepads
	var gamepads = Input.get_connected_joypads()
	print("gamepads %s (%s)"%[gamepads, gamepads.size()])
	for i in range(gamepads.size()):
		print("  %s- \"%s\" %s"%[i, Input.get_joy_name(i), Input.get_joy_guid(i)])

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
		OS.window_fullscreen = !OS.window_fullscreen
		if not OS.window_fullscreen:
			OS.set_window_size(minimum_size)
	
