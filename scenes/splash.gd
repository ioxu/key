extends Node2D

func _ready():
	$menu_root/VBoxContainer/new_container_button.grab_focus()
	
	var root = get_node("/root")
	root.connect("size_changed",Callable(self,"resize"))
	resize()
	

func resize():
	var window_size = DisplayServer.window_get_size()#OS.get_window_size()
	$Control/splash_image.set_scale(Vector2( window_size.x/1920.0, window_size.y/1080.0) )


func _input(_event):
#	if event.is_action_pressed("ui_skip"):
#		print("splash ui_skip")
#		Game.start()
	pass


func _on_old_start_button_button_up():
	Game.start()


func _on_new_container_button_button_up():
	var to_scene = "res://scenes/game_container.tscn"
	var err = get_tree().change_scene_to_file(to_scene)
	print("[splash] %s change_scene_to_file error: %s"%[to_scene, err])
	var vp = get_viewport()
	if vp: 
		vp.set_input_as_handled()
