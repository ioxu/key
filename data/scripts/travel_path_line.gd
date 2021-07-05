extends Spatial
class_name TravelPath, "res://data/TravelPath/TravelPath_icon.png"
#export(NodePath) var track_object_path
#onready var track_object = get_node(track_object_path)

var point_array = Array()
export var draw_points := false
export var distance_threshold := 0.65
export var max_points := 200

export var position_offset := Vector3.ZERO
export var trail_colour : Color = Color(0.917969, 0.075302, 0.233302)
export var emission_multiplier := 1.0
onready var travel_path = ImmediateGeometry.new()
onready var track_object = null
onready var last_position := Vector3.ZERO
onready var trail_material = preload("res://data/shaders/trail_shader_material.tres")
onready var falloff_lut = Util.bias_lut(0.22, 50)

func _ready():
	#set_as_toplevel(true)
	track_object = get_node("../")
	last_position = track_object.global_transform.origin
	point_array.append(last_position)
	travel_path.material_override = trail_material.duplicate()
	travel_path.material_override.set_shader_param("albedo", trail_colour)
	travel_path.material_override.set_shader_param("emission", trail_colour * emission_multiplier)
	get_node("/root/").add_child(travel_path)

func _process(delta):
	draw_line(delta)
	
func draw_line(delta):
	if is_instance_valid(track_object) and track_object and (track_object.global_transform.origin - point_array.back()).length() > distance_threshold:
		point_array.append(track_object.global_transform.origin + position_offset)
		if point_array.size() > max_points:
			point_array.pop_front()

	travel_path.clear()
	travel_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
	var p_size = point_array.size()
	
	for i in range(p_size):
		if i !=0:
			travel_path.set_color(trail_colour * Color(1.0, 1.0, 1.0, falloff_lut.interpolate_baked(float(i)/p_size)))
		else:
			travel_path.set_color(trail_colour * Color(1.0, 1.0, 1.0, 0.0))
		travel_path.add_vertex(point_array[i])

	if is_instance_valid(track_object) and track_object:
		# add point from track_object's present location to end of path
		# (avoid a gap that pops out once distance_threshold is reached)
		travel_path.set_color(trail_colour)
		travel_path.add_vertex(track_object.global_transform.origin)

	travel_path.end()

	if draw_points:
		travel_path.begin(Mesh.PRIMITIVE_POINTS)
		for i in range(p_size):
			if i !=0:
				travel_path.set_color(trail_colour * Color(1.0, 1.0, 1.0, falloff_lut.interpolate_baked(float(i)/p_size)))
			else:
				travel_path.set_color(trail_colour * Color(1.0, 1.0, 1.0, 0.0))
			travel_path.add_vertex(point_array[i])
		travel_path.end()


