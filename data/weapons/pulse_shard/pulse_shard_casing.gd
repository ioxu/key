extends RigidBody3D

var sfx_played = false

var base_pitch_scale := 1.0


func _process(_delta):
	#set_angular_velocity( Vector3.ZERO )
	var f = Util.bias($Timer.time_left / $Timer.wait_time, 0.15)
	$MeshInstance3D.mesh.surface_get_material(0).albedo_color.a = f * 1.0
	base_pitch_scale = $AudioStreamPlayer3D.get_pitch_scale()


func _on_Timer_timeout():
	self.queue_free()


func _on_body_entered(_body):
	if sfx_played != true:
		$AudioStreamPlayer3D.pitch_scale = randf_range(base_pitch_scale - 0.1, base_pitch_scale)
		$AudioStreamPlayer3D.play()
		sfx_played = true
