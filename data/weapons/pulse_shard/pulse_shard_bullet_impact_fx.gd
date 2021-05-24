extends Spatial
var mat
var shader_time = 0.0
const sparks_fx_scene = preload("res://data/effects/sparks.tscn")
var sparks_fx
export var effect_time = 0.18
var lightInitialEnergy = 0.0


func _ready():
	$free_timer.start()
	mat = $MeshInstance.material_override
	mat.set_shader_param("time_offset", randf()*13.775 )
	$MeshInstance.scale = Vector3(rand_range(0.75,1.75), rand_range(0.75,1.75), 1.0)
	$MeshInstance.rotation_degrees = Vector3(0.0, 0.0, rand_range(-180.0, 180.0))
	$sparks/Particles.emitting = true
	lightInitialEnergy = $OmniLight.light_energy


func _process(delta):
	shader_time += delta
	#mat = $MeshInstance.material_override
	mat.set_shader_param("shader_time", clamp(Util.remap( shader_time, 0.0, effect_time, 0.0, 1.0 ), 0.0, 1.0 ) )
	var lenergy = clamp(Util.remap( shader_time, 0.0, effect_time, 1.0, 0.0 ), 0.0, 1.0)
	$OmniLight.light_energy =  lenergy * lightInitialEnergy * 3.0
	
	if shader_time >= effect_time:
		$MeshInstance.visible = false


func _on_free_timer_timeout():
	self.queue_free()

