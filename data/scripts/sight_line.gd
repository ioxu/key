extends ImmediateGeometry

var from := Vector3.ZERO
var to := Vector3.ZERO

onready var material = preload("res://data/shaders/sight_line.material")

func _ready():
	set_as_toplevel(true)
	material_override = material
	
func _process(delta):
	if visible:
		clear()
		begin(Mesh.PRIMITIVE_LINE_STRIP)
		add_vertex(from)
		add_vertex(to)
		end()
	
