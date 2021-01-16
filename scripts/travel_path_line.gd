extends ImmediateGeometry

var point_array = Array()

export var distance_threshold := 0.4
export(NodePath) var track_object_path
export var position_offset := Vector3.ZERO


onready var track_object = get_node(track_object_path)
onready var last_position := Vector3.ZERO

onready var trail_material = preload("res://data/shaders/trai_material.tres")

func _ready():
	set_as_toplevel(true)
	last_position = track_object.global_transform.origin
	point_array.append(last_position)
	material_override = trail_material

func _process(delta):
	if (track_object.global_transform.origin - point_array.back()).length() > distance_threshold:
		point_array.append(track_object.global_transform.origin + position_offset)
	
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in point_array:
		add_vertex(p)
	end()
