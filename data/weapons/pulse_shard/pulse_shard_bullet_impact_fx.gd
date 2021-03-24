extends Spatial
var mat
var shader_time = 0.0

func _ready():
	$free_timer.start()
	mat = $MeshInstance.material_override
	mat.set_shader_param("time_offset", randf()*13.775 )
	$MeshInstance.scale = Vector3(rand_range(0.5,2.25), rand_range(0.5,2.25), 1.0)
	$MeshInstance.rotation_degrees = Vector3(0.0, 0.0, rand_range(-180.0, 180.0))


func _process(delta):
	shader_time += delta
	mat = $MeshInstance.material_override
	mat.set_shader_param("shader_time", Util.remap( shader_time, 0.0, $free_timer.get_wait_time(), 0.0, 1.0 ) )


func _on_free_timer_timeout():
	self.queue_free()

