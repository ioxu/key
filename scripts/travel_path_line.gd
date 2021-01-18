extends ImmediateGeometry

var point_array = Array()

export var distance_threshold := 0.55
export(NodePath) var track_object_path
export var position_offset := Vector3.ZERO


onready var track_object = get_node(track_object_path)
onready var last_position := Vector3.ZERO

#onready var trail_material = preload("res://data/shaders/trail_material.tres")
onready var trail_material = preload("res://data/shaders/trail_shader_material.tres")


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
	#for p in point_array:
	var p_size = point_array.size()
	for i in range(p_size):
		if i !=0:
			set_color(Color(0.17, 0.66, 0.77, bias(float(i)/p_size, 0.22)))
		else:
			set_color(Color(0.17, 0.66, 0.77, 0.0))
		#add_vertex(p)
		add_vertex(point_array[i])
	end()

func bias(value, b):
	b = -log2(1.0 - b)
	return 1.0 - pow(1.0 - pow(value, 1.0/b), b)

func log2(value):
	return log(value) / log(2)
