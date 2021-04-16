extends Node

var player = null
var level = null

func _ready():
	print("game.dg autoload ready")
	
	# peep gamepads
	var gamepads = Input.get_connected_joypads()
	print("gamepads %s (%s)"%[gamepads, gamepads.size()])
	for i in range(gamepads.size()):
		print("  %s- \"%s\" %s"%[i, Input.get_joy_name(i), Input.get_joy_guid(i)])


func start() -> void:
	prints("game.gd", "start()", "res://scenes/level.tscn")
	get_tree().change_scene("res://scenes/level.tscn")
	get_tree().set_input_as_handled()
#	level = get_tree().get_current_scene()#.find_node("Level")
#	prints("game.gd", "level", level.get_path(), level.level_name)
#	player = level.find_node("player")
#	prints("game.gd", "player", player.get_path())


func enter_door(door_name, connected_scene, connected_door) -> void:
	prints("game.gd", "enter_door", door_name, connected_scene, connected_door)
	get_tree().change_scene(connected_scene)
