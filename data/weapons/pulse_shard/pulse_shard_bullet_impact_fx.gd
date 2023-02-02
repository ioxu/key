extends Node3D
var mat
var shader_time = 0.0
const sparks_fx_scene = preload("res://data/effects/sparks.tscn")
var sparks_fx
@export var effect_time = 0.18
@export var decal_time = 1.5
var light_energy_initial = 0.0
var scale_min = 0.75
var scale_max = 1.75 * 2.0

var decal_emission_energy_initial = 0.0

func _ready():
	$free_timer.start()
	mat = $MeshInstance3D.material_override
	mat.set_shader_parameter("time_offset", randf()*13.775 )
	$MeshInstance3D.scale = Vector3(randf_range(scale_min, scale_max), randf_range(scale_min, scale_max), 1.0)
	#$MeshInstance3D.rotation_degrees = Vector3(0.0, 0.0, randf_range(-180.0, 180.0))
	$MeshInstance3D.rotation = Vector3(0.0, 0.0, randf_range(-PI, PI))
	$sparks/GPUParticles3D.emitting = true
	$OmniLight3D.visible = false
	light_energy_initial = $OmniLight3D.light_energy
	decal_emission_energy_initial = $Decal.emission_energy
	$Decal.rotation = Vector3(-PI/2.0, randf_range(-PI, PI) * 0.25, 0.0)
	
	$AudioStreamPlayer3D.set_pitch_scale( randf_range(0.65, 1.5) )
	$AudioStreamPlayer3D.set_volume_db( randf_range(0.0, 4.0) )
	$AudioStreamPlayer3D.play()

func start() -> void:
	#pprint("start()")
	$OmniLight3D.visible = true



func _process(delta):
	#pprint("BULLET IMACT SHADERTIME %s"%shader_time)
	shader_time += delta
	#mat = $MeshInstance3D.material_override
	mat.set_shader_parameter("shader_time", clamp(Util.remap_unclamped( shader_time, 0.0, effect_time, 0.0, 1.0 ), 0.0, 1.0 ) )
	var lenergy = clamp(Util.remap_unclamped( shader_time, 0.0, effect_time, 1.0, 0.0 ), 0.0, 1.0)
	$OmniLight3D.light_energy =  lenergy * light_energy_initial * 3.0
	var decal_energy = clamp(Util.remap_unclamped( shader_time, 0.0, decal_time, 1.0, 0.0 ), 0.0, 1.0)
	decal_energy = Util.bias( decal_energy, 0.1 )
	$Decal.emission_energy= decal_energy * decal_emission_energy_initial
	
	if shader_time >= effect_time:
		$MeshInstance3D.visible = false


func _on_free_timer_timeout():
	$OmniLight3D.visible = false
	#pprint(" .. timeout")
	self.queue_free()


func pprint(thing) -> void:
	print("[pulse_shard_bullet_impact_fx] %s"%str(thing))
