extends MeshInstance3D

@onready var material = mesh.surface_get_material(0).duplicate()


func _ready():
	self.set_surface_override_material(0, material)
	await get_tree().create_timer(0.05).timeout
	material.set_shader_parameter("factor", -1.0)


func set_factor(factor):
	material.set_shader_parameter("factor", clamp(factor, 0.0, 1.0))
