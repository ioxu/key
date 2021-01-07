extends Node2D

func _ready():
	var root = get_node("/root")
	root.connect("size_changed",self,"resize")
	resize()


func resize():
	var window_size = OS.get_window_size()
	$Control/splash_image.set_scale(Vector2( window_size.x/1920.0, window_size.y/1080.0) )


func _input(event):
	#if event.is_action_pressed("ui_skip"):
	if event.is_action_pressed("ui_skip"):
		# next screen
		get_tree().change_scene("res://scenes/level.tscn")
		get_tree().set_input_as_handled()
