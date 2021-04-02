extends Node

func _ready():
	print("game.dg autoload ready")
	
	# peep gamepads
	var gamepads = Input.get_connected_joypads()
	print("gamepads %s (%s)"%[gamepads, gamepads.size()])
	for i in range(gamepads.size()):
		print("  %s- \"%s\" %s"%[i, Input.get_joy_name(i), Input.get_joy_guid(i)])


func start():
	prints("game.gd", "start()", "res://scenes/level.tscn")
	get_tree().change_scene("res://scenes/level.tscn")
	get_tree().set_input_as_handled()
