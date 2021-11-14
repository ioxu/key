extends Node2D

var global_time = 0

onready var db = $debug2

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_time += delta
	db.rect_position = Vector2( 0.0, fmod(global_time * 150 ,512.0) )
