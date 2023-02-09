extends Node

var player_scene = preload("res://scenes/player/player.tscn")

var level_scene = preload("res://scenes/level_00.tscn")

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
	#prints("[game.gd]", "start()", level_scene.get_path() )#"res://scenes/level.tscn")
	prints("[game.gd]", "start()", "res://scenes/level_00.tscn")
	#var level_instance = level_scene.instantiate()
	#print( "[game.gd] level_instance %s"%level_instance )
	var err = get_tree().change_scene_to_file("res://scenes/level_00.tscn")
	print("[game.gd] change_scene_to_file error: %s"%err)
	get_viewport().set_input_as_handled()#get_tree().set_input_as_handled()
	passthrough_door = "start"

	# instantiate player
	player = player_scene.instantiate()
	player.connect("has_died",Callable(self,"_on_player_die"))
#	var err = get_tree().get_root().add_child( level_instance )  #.change_scene_to_file("res://scenes/level.tscn")
#	print("[game.gd] change_scene_to_file error: %s"%err)

	#get_viewport().set_debug_draw( Viewport.DEBUG_DRAW_SSIL )


func quit() -> void:
	get_tree().quit()


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
	get_tree().change_scene_to_file(connected_scene)
	passthrough_door = connected_door


func level_ready(level):
	# once level is ready
	# find passthrough_door and enter level through it
	prints("[game.gd][level_ready]", level.level_name, "enter through door", "'%s'"%passthrough_door )
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
	await get_tree().create_timer(1.0).timeout
	player.visible = true
	player.set_active(true)
	player.add_additional_force(door_object.global_transform.basis.z.normalized() * 800.0)
	last_door_exited = door_object.door_name


func find_door(door_name) -> Node:
	
	print(" -> find_door")
	
	for c in current_level.get_node("level").get_children():
		
		#print("     get_class %s %s"%[c, c.get_class()])
		
		if c.has_method("get_class_name"):
			if c.get_class_name() == "door":
				if c.door_name == door_name:
					prints(" found door", "'"+c.door_name+"'", c.get_path())
					return c
	return null


func set_SSAO(value):
	prints("SETTING SSAO FROM GAME AUTOLOAD", value)
	current_level.get_node("WorldEnvironment").environment.ssao_enabled = value
