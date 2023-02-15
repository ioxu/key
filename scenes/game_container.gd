extends Node2D

var gtime := 0.0

# store
var _initial_player_camera_transform : Transform3D

@onready var player_camera : Camera3D = $SubViewportContainer/SubViewport.find_child("Camera3D")
@onready var starting_camera : Camera3D =  $SubViewportContainer/SubViewport.find_child("starting_Camera3D")

# starting_camera noise
var starting_cam_p_noise := FastNoiseLite.new()
var starting_cam_o_noise := FastNoiseLite.new()

var starting_camera_transform : Transform3D

var _do_starting_camera_match := true

func _ready():
	# 1st time running:
	# do start menu setup and diorama stuff

	# deactivate player
	var player = $SubViewportContainer/SubViewport.find_child("player")
	pprint("setting player to inactive (%s)"%player.get_path())
	player.active = false #true #false

	# stash camera transform
	#var camera = player.find_child("Camera3D")
	pprint("player camera %s"%player_camera.get_path())
	_initial_player_camera_transform = Transform3D(player_camera.transform)

	starting_camera_transform = starting_camera.global_transform
	# set camera to diorama camera
	# starting_camera noise
	starting_cam_p_noise.frequency = 0.25
		
	#set
	player_camera.set_global_transform( starting_camera.global_transform )

	# menu ui
	$ui_starting_menu.connect("new_game_selected", self.new_game_start) 
	$ui_starting_menu.find_child("new_game_button").grab_focus()


func _process(delta):
	gtime += delta
	
	# move target around with noise
	# position
	starting_cam_p_noise.set_seed(0)
	starting_cam_p_noise.frequency = 0.1
	var _x = starting_cam_p_noise.get_noise_3dv( starting_camera_transform.origin + Vector3(0, 0, gtime))
	starting_cam_p_noise.set_seed(1)
	starting_cam_p_noise.frequency = 0.25
	var _y = starting_cam_p_noise.get_noise_3dv( starting_camera_transform.origin + Vector3(0, 0, gtime))
	starting_cam_p_noise.set_seed(2)
	starting_cam_p_noise.frequency = 0.1
	var _z = starting_cam_p_noise.get_noise_3dv( starting_camera_transform.origin + Vector3(0, 0, gtime) ) 
	starting_camera.transform.origin = starting_camera_transform.origin + Vector3(_x, _y, _z) * Vector3(0.2, 0.1, 0.2)

	starting_cam_o_noise.set_seed(3)
	starting_cam_o_noise.frequency = 0.1 * 0.5
	_x = starting_cam_o_noise.get_noise_3dv( starting_camera_transform.origin + Vector3(0, 0, gtime))
	starting_cam_o_noise.set_seed(4)
	starting_cam_o_noise.frequency = 0.25 * 0.5
	_y = starting_cam_o_noise.get_noise_3dv( starting_camera_transform.origin + Vector3(0, 0, gtime))
	starting_cam_o_noise.set_seed(5)
	starting_cam_o_noise.frequency = 0.1 * 0.5
	_z = starting_cam_o_noise.get_noise_3dv( starting_camera_transform.origin + Vector3(0, 0, gtime) ) 
	
	starting_camera.transform = starting_camera.transform.rotated_local( Vector3.RIGHT, _x * .1 )
	starting_camera.transform = starting_camera.transform.rotated_local( Vector3.UP, _y * .2 )
	starting_camera.transform = starting_camera.transform.rotated_local( Vector3.FORWARD, _z * 0.5)#.3 )
	
	starting_camera.transform.basis = starting_camera.transform.interpolate_with( starting_camera_transform, 0.85 ).basis

	if _do_starting_camera_match:
		player_camera.set_global_transform( starting_camera.global_transform )


func new_game_start() -> void:
	pprint("new_game_start()")
	# TODO: CHARACTER GETS X BUTTON AND JUMPS
#	$SubViewportContainer/SubViewport.set_input_as_handled()
#	get_viewport().set_input_as_handled()

	# begin tween of camera back to starting transform
	_do_starting_camera_match = false
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans( Tween.TRANS_CUBIC )
	tween.tween_property(player_camera, "transform", _initial_player_camera_transform, 4.0 )

	# enable character
	var player = $SubViewportContainer/SubViewport.find_child("player")
	#await get_tree().create_timer(1.0).timeout
	pprint("enable character")
	player.active = true #false


func pprint(thing) -> void:
	print_rich("[code][b][color=Greenyellow][game_container][/color][/b][/code] %s" %str(thing))
