extends Node2D

var gtime := 0.0

# store
var _initial_player_camera_transform : Transform3D

@onready var player_camera : Camera3D = $SubViewportContainer/SubViewport.find_child( "Camera3D" )
@onready var starting_camera : Camera3D =  $SubViewportContainer/SubViewport.find_child( "starting_Camera3D" )
@onready var fly_camera : Camera3D = $SubViewportContainer/SubViewport.find_child( "fly_Camera" )

var _previous_camera : Camera3D


# starting_camera noise
var starting_cam_p_noise := FastNoiseLite.new()
var starting_cam_o_noise := FastNoiseLite.new()

var starting_camera_transform : Transform3D
var starting_camera_interlocal_node : Node3D

var cam_tween_weight := 0.0
var _do_starting_camera_match := true

var enemy_scene = preload( "res://data/enemies/Enemy.tscn" )

signal mouse_motion_relative(relative)


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
	#_initial_player_camera_transform = Transform3D(player_camera.transform)
	_initial_player_camera_transform = Transform3D(player_camera.global_transform)

	starting_camera_transform = starting_camera.global_transform
	# set camera to diorama camera
	# starting_camera noise
	starting_cam_p_noise.frequency = 0.25
		
	#set
	player_camera.set_global_transform( starting_camera.global_transform )
	starting_camera_interlocal_node = Node3D.new()
	player_camera.get_parent().add_child( starting_camera_interlocal_node )

	# menu ui
	$ui_starting_menu.connect("new_game_selected", self.new_game_start) 
	$ui_starting_menu.find_child("new_game_button").grab_focus()

 
func _process(delta):
	gtime += delta

	if _do_starting_camera_match:
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

		player_camera.set_global_transform( starting_camera.global_transform )

		starting_camera_interlocal_node.set_global_transform( starting_camera.global_transform )

		player_camera.transform.origin = starting_camera_interlocal_node.transform.origin.slerp( Vector3(), cam_tween_weight )
		player_camera.transform.basis = starting_camera_interlocal_node.transform.basis.slerp( Basis(), cam_tween_weight )


func new_game_start() -> void:
	pprint("new_game_start()")
	# TODO: CHARACTER GETS X BUTTON AND JUMPS
#	$SubViewportContainer/SubViewport.set_input_as_handled()
#	get_viewport().set_input_as_handled()

	# begin tween of camera back to starting transform
	var tween = self.create_tween()
	tween.connect( "finished", tween_finished )
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans( Tween.TRANS_CUBIC )
	tween.tween_interval(0.75)
	tween.tween_property(self, "cam_tween_weight", 1.0, 5.0).from(0.0)

	# enable character
	var player = $SubViewportContainer/SubViewport.find_child("player")
	pprint("enable character")
	player.active = true


	var n = 20#15#50#200
	
	var near = 17
	var far = 50
	var _lh = self.find_child("level_hook")
	for i in range(n):
		var e = enemy_scene.instantiate()
		var c = (i/float(n)) * 2.0*PI 
		var pp = Vector3(0.0, 2.0, randf_range(near, far))
		pp = pp.rotated(Vector3.UP, randf()*125.3)
		e.position = pp
		_lh.add_child(e)


func _input(event):
	# pass mouse relative motion to the fly_camera
	if event is InputEventMouseMotion:
		emit_signal( "mouse_motion_relative", event.relative )


func tween_finished() ->void:
	pprint("camera tween finished, cleaning up")
	_do_starting_camera_match = false
	starting_camera_interlocal_node.queue_free()


func pprint(thing) -> void:
	print_rich("[code][b][color=Greenyellow][game_container][/color][/b][/code] %s" %str(thing))
