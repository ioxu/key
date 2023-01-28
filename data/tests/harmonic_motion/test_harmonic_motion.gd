extends Node2D

const harmonic_motion_lib = preload("res://data/scripts/harmonic_motion.gd")
var harmonic_motion = harmonic_motion_lib.new()

@export var damping_ratio = 0.45 : set = set_damping_ratio
@export var angular_frequency = 6.0 : set = set_aungular_frequency


func _ready():
	randomize()
	harmonic_motion.initialise( damping_ratio, angular_frequency )


func _process(delta):
	$Sprite2D.position = harmonic_motion.calculate_v2( $Sprite2D.position, $target_sprite.position )


func set_damping_ratio(new_value):
	damping_ratio = new_value
	harmonic_motion.initialise(damping_ratio, angular_frequency)


func set_aungular_frequency(new_value):
	angular_frequency = new_value
	harmonic_motion.initialise(damping_ratio, angular_frequency)


func _on_Timer_timeout():
	var v_size = get_viewport().size
	$target_sprite.position = Vector2(randf_range(v_size.x * 0.15, v_size.x - (v_size.x * 0.15) ),
									randf_range(v_size.y * 0.15, v_size.y - (v_size.y * 0.15) )
									)
