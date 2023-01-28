extends Node
# main game singleton

var minimum_size : Vector2 = Vector2(1024,576)#(960, 540)
var BORDERLESS_FULLSCREEN = true#false

var window_position := Vector2.ZERO
var fullscreen : = false


func _ready():
	pprint("window.dg autoload ready")
	var root = get_node("/root")
	root.connect("size_changed",Callable(self,"resize"))
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

	pprint("get_windows_size %s"%DisplayServer.window_get_size()) #OS.get_window_size())
	pprint("get_screen_size %s"%DisplayServer.screen_get_size())#OS.get_screen_size())

	window_position = DisplayServer.window_get_position() #OS.get_window_position()

	if fullscreen:
		if not BORDERLESS_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_position( Vector2i(0,0) )#OS.set_window_position(Vector2(0.0, 0.0))
			DisplayServer.window_set_size( DisplayServer.screen_get_size() )#OS.set_window_size(OS.get_screen_size())
			#OS.set_borderless_window(true)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	elif event.is_action_pressed("ui_fullscreen"):
		_go_fullscreen()
		get_viewport().set_input_as_handled() #get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_reset"):
		get_tree().reload_current_scene()


func resize():
	var root = get_node("/root")
	var resolution = root.get_visible_rect() #root.get_rect()
	pprint("resolution: %s"%resolution)


func _go_fullscreen() -> void:
	if not BORDERLESS_FULLSCREEN:

		# flip fullscreen/windowed mode
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_WINDOWED:
				pprint("windowed -> fullscreen")
				DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_FULLSCREEN )
			DisplayServer.WINDOW_MODE_FULLSCREEN:
				pprint("fullscreen -> windowed")
				DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_WINDOWED )
		fullscreen = !fullscreen

		if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN :#OS.window_fullscreen:
			DisplayServer.window_set_size( minimum_size )#OS.set_window_size(minimum_size)
			#OS.set_borderless_window(false)
		else:
			DisplayServer.window_set_position(window_position)# OS.set_window_position(window_position)
	else:
		fullscreen = !fullscreen
		#pprint(" -> fullscreen: %s"%fullscreen)
		if fullscreen:
			pprint("windowed -> fullscreen")
			DisplayServer.window_set_size( DisplayServer.screen_get_size() ) #OS.set_window_size(OS.get_screen_size())
			#OS.set_borderless_window(true)
			DisplayServer.window_set_position( Vector2i(0,0) )#OS.set_window_position(Vector2(0.0, 0.0))
			
		else:
			pprint("fullscreen -> windowed")
			#OS.set_borderless_window(false)
			DisplayServer.window_set_size( minimum_size ) #OS.set_window_size(minimum_size)
			DisplayServer.window_set_position( window_position )#OS.set_window_position(window_position)


func pprint(thing) -> void:
	print("[window] %s"%str(thing))
