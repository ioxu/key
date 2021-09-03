extends Node2D


const harmonic_motion_lib = preload("res://data/scripts/harmonic_motion.gd")
var harmonic_motion = harmonic_motion_lib.new()
var parms = {} 

var target_pos = Vector2.ZERO

var pvx = 0.0
var pvy = 0.0

export var damping_ratio = 0.45 setget set_damping_ratio
export var angular_frequency = 6.0 setget set_aungular_frequency


func _ready():
	parms = harmonic_motion.CalcDampedSpringMotionParams( damping_ratio, angular_frequency )
	prints("harmonic_motion",harmonic_motion)


func _process(delta):
	var cx = harmonic_motion.calculate( $Sprite.position.x, pvx, target_pos.x, parms )
	var cy = harmonic_motion.calculate( $Sprite.position.y, pvy, target_pos.y, parms )
#	var cx = harmonic_motion.calculate( $Sprite.position.x, target_pos.x, parms )
#	var cy = harmonic_motion.calculate( $Sprite.position.y, target_pos.y, parms )
	$Sprite.position.x = cx[0]
	$Sprite.position.y = cy[0]
#	$Sprite.position.x = cx
#	$Sprite.position.y = cy

	pvx = cx[1]
	pvy = cy[1]


func set_damping_ratio(new_value):
	damping_ratio = new_value
	parms = harmonic_motion.CalcDampedSpringMotionParams( damping_ratio, angular_frequency )


func set_aungular_frequency(new_value):
	angular_frequency = new_value
	parms = harmonic_motion.CalcDampedSpringMotionParams( damping_ratio, angular_frequency )


func _on_Timer_timeout():
	var v_size = get_viewport().size
	target_pos.x = rand_range(v_size.x * 0.15, v_size.x - (v_size.x * 0.15) )
	target_pos.y = rand_range( v_size.y * 0.15, v_size.y - (v_size.y * 0.15) )
	$target_sprite.position.x = target_pos.x
	$target_sprite.position.y = target_pos.y
	
	
