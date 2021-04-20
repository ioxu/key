extends Node

var player_scene = preload("res://scenes/player/player.tscn")
var player = null
var current_level = null

var passthrough_door = null
var last_door_exited = null

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
	passthrough_door = "start"
	
	# instantiate player
	player = player_scene.instance()
	player.connect("die", self, "_on_player_die")


func _on_player_die(object):
	prints("game.gd _on_player_die", object.get_path())
	player.respawn()
	player.set_active(false)
	player.visible = false
	exit_door(last_door_exited)



func enter_door(door_name, connected_scene, connected_door) -> void:
	prints("game.gd", "enter_door", door_name, connected_scene, connected_door)
	# unparent player
	#get_tree().get_current_scene().remove_child(player)
	player.get_parent().remove_child(player)
	get_tree().change_scene(connected_scene)
	passthrough_door = connected_door


func level_ready(level):
	# once level is ready
	# find passthrough_door and enter level through it
	prints("Game.gd level_ready", level.level_name, "enter through door", "'"+passthrough_door+"'" )
	current_level = level

	# reparent player
	level.add_child(player)
	player.set_active(false)
	player.visible = false
	player.add_level_visit(level.level_name, passthrough_door)

	exit_door(passthrough_door)
	passthrough_door = null


func exit_door(door) -> void:
	prints("exit_door", door)
	var door_object = find_door(door)

	# place player in front, and shove player outta the door
	player.global_transform.origin = door_object.global_transform.origin  +\
		( door_object.global_transform.basis.z * 1.5)
	yield(get_tree().create_timer(1.0), "timeout")
	player.visible = true
	player.set_active(true)
	player.add_additional_force(door_object.global_transform.basis.z.normalized() * 800.0)
	last_door_exited = door_object.door_name


func find_door(door_name) -> Node:
	for c in current_level.get_node("level").get_children():
		if c.get_class() == "door":
			if c.door_name == door_name:
				prints(" found door", "'"+c.door_name+"'", c.get_path())
				return c
	return null
