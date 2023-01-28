extends MeshInstance3D
#extends Node3D
#extends ImmediateMesh

var this_is = "sight_line"
var from := Vector3.ZERO
var to := Vector3.ZERO

@onready var material = preload("res://data/shaders/sight_line.material")

func _ready():
	mesh = ImmediateMesh.new()
	set_as_top_level(true)
	material_override = material
	pass
	
func _process(delta):
	if visible:
		#pprint("from: %s"%from)
		#pprint("to: %s"%to)
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		mesh.surface_add_vertex(from)
		mesh.surface_add_vertex(to)
		mesh.surface_end()
	pass


func pprint(thing) -> void:
	print("[sight_line] %s"%str(thing))
