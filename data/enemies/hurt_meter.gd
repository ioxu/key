extends MeshInstance

onready var material = mesh.surface_get_material(0).duplicate()


func _ready():
	self.set_surface_material(0, material)
	yield(get_tree().create_timer(0.05), "timeout")
	material.set_shader_param("factor", -1.0)


func set_factor(factor):
	material.set_shader_param("factor", clamp(factor, 0.0, 1.0))
