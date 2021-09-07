extends Node2D


const harmonic_motion_lib = preload("res://data/scripts/harmonic_motion.gd")
var harmonic_motion_x = harmonic_motion_lib.new()
var harmonic_motion_y = harmonic_motion_lib.new()

var target_pos = Vector2.ZERO

var pvx = 0.0
var pvy = 0.0

export var damping_ratio = 0.45 setget set_damping_ratio
export var angular_frequency = 6.0 setget set_aungular_frequency


func _ready():
	harmonic_motion_x.initialise(damping_ratio, angular_frequency)
	harmonic_motion_y.initialise(damping_ratio, angular_frequency)


func _process(delta):
	$Sprite.position.x = harmonic_motion_x.calculate_c( $Sprite.position.x, target_pos.x)
	$Sprite.position.y = harmonic_motion_y.calculate_c( $Sprite.position.y, target_pos.y)


func set_damping_ratio(new_value):
	damping_ratio = new_value
	harmonic_motion_x.initialise(damping_ratio, angular_frequency)
	harmonic_motion_y.initialise(damping_ratio, angular_frequency)


func set_aungular_frequency(new_value):
	angular_frequency = new_value
	harmonic_motion_x.initialise(damping_ratio, angular_frequency)
	harmonic_motion_y.initialise(damping_ratio, angular_frequency)


func _on_Timer_timeout():
	var v_size = get_viewport().size
	target_pos.x = rand_range(v_size.x * 0.15, v_size.x - (v_size.x * 0.15) )
	target_pos.y = rand_range( v_size.y * 0.15, v_size.y - (v_size.y * 0.15) )
	$target_sprite.position.x = target_pos.x
	$target_sprite.position.y = target_pos.y
	
	
