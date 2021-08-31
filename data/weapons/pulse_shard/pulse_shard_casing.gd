extends RigidBody


func _process(delta):
	var f = Util.bias($Timer.time_left / $Timer.wait_time, 0.15)
	$MeshInstance.mesh.surface_get_material(0).albedo_color.a = f * 1.0


func _on_Timer_timeout():
	self.queue_free()
