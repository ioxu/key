extends Area3D

@export var jump_force := Vector3(0.0, 4000.0, 0.0)
@export var multiply_velocity := true


var _entered_bodies = []


func _ready():
	pass


func _on_jumpPad_body_shape_entered(body_id, body, body_shape, local_shape):
	$Timer.start()
	_entered_bodies.append( body )


func _on_Timer_timeout():
	for b in _entered_bodies:
		if b.has_method( "add_additional_force" ):
			b.add_additional_force(jump_force)


func _on_jumpPad_body_shape_exited(body_id, body, body_shape, local_shape):
	prints("jumpPad exited: ", self, "body_id", body_id, "body", body, "(" , body.get_path(), ")",  "body_shape", body_shape, "local_shape", local_shape)
	$Timer.stop()
	_entered_bodies.erase( body )

