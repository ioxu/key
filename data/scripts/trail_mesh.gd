extends Node3D
class_name TrailRenderer

# thank you IndieQuest!
# originally https://github.com/IndieQuest/DogFightTutorial/blob/master/TrailRenderScriptClass/TrailRender.gd

# width
@export var width: float = 0.5
@export var width_curve: Curve
@export_node_path("Node3D") var rotation_constrain

# length
@export var time_interval_to_add_point : float = 0.05
@export var distance_step = 0.65

@export var max_points := 100
@export var material: Material
# show or hide
@export var render: bool = true

@onready var half_width = width * 0.5
var points := []


var life_frames : = 0
var _time_since_last_point := 0.0
var life_time : = 0.0

var surfacetool : SurfaceTool


func _ready() -> void:
	surfacetool = SurfaceTool.new()
	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var node = Node.new()
	node.name = "Node"
	add_child(node)

	var render = MeshInstance3D.new()
	render.name = "Render"
	node.add_child(render)
	render.top_level = true
	
	rotation_constrain = get_node( rotation_constrain )


func _process(delta: float) -> void:
	life_frames+=1
	life_time += delta
	if render:
		# add new point and render
		#if life_frames%2 == 0 :
		if _time_since_last_point >= time_interval_to_add_point:
			add_point()
			_time_since_last_point = 0.0
		else:
			first_point()
		_draw_trail()
		_time_since_last_point +=delta
	else:
		# slowly hide the trail
		if points.size() > 0:
			var last_point = points.pop_back()
			last_point.queue_free()


func first_point() -> void:
	if points.size() > 1:
		var new_point = Transform3D()
		new_point.origin = self.global_transform.origin
		if rotation_constrain:
			new_point.basis = rotation_constrain.global_transform.basis
		else:
			new_point.basis = self.global_transform.basis
		
		points[0] = new_point


func add_point() -> void:
	var new_point = Transform3D()
	new_point.origin = self.global_transform.origin
	if rotation_constrain:
		new_point.basis = rotation_constrain.global_transform.basis
	else:
		new_point.basis = self.global_trasnform.basis
	points.insert(0, new_point)
	if points.size() > max_points:
		var last_point = points.pop_back()


func _draw_trail() -> void:
	if points.size() < 2:
		return
	# create surface tool
	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# draw triangles
	for i in range(points.size() - 1):
		_points_to_rect(surfacetool, points[i], points[i + 1], i)
	# commit
	surfacetool.generate_normals()
#	st.generate_tangents()
	$Node/Render.mesh = surfacetool.commit()
	$Node/Render.set_surface_override_material(0, material)


func _points_to_rect(st: SurfaceTool, p1: Transform3D, p2: Transform3D, idx: float) -> void:
	var num_points = points.size() - 1
	
	var offset1 = idx / num_points
	var mod1 = half_width * width_curve.sample(offset1)
	
	var v1 = p1.origin # + p1.basis.x * mod1
	var uv1 = Vector2(0, offset1)
	
	var v2 = p1.origin - p1.basis.x * mod1
	var uv2 = Vector2(1, offset1)
	
	var offset2 = (idx + 1) / num_points
	var mod2 = half_width * width_curve.sample(offset2)
	
	var v3 = p2.origin # + p2.basis.x * mod2
	var uv3 = Vector2(0, offset2)
	
	var v4 = p2.origin - p2.basis.x * mod2
	var uv4 = Vector2(1, offset2)

	st.set_smooth_group(-1)
	st.set_uv(uv1)
	st.add_vertex(v1)
	st.set_uv(uv2)
	st.add_vertex(v2)
	st.set_uv(uv3)
	st.add_vertex(v3)
	
	st.set_uv(uv3)
	st.add_vertex(v3)
	st.set_uv(uv2)
	st.add_vertex(v2)
	st.set_uv(uv1)
	st.add_vertex(v1)
	
	st.set_uv(uv3)
	st.add_vertex(v3)
	st.set_uv(uv4)
	st.add_vertex(v4)
	st.set_uv(uv2)
	st.add_vertex(v2)
	
	st.set_uv(uv2)
	st.add_vertex(v2)
	st.set_uv(uv4)
	st.add_vertex(v4)
	st.set_uv(uv3)
	st.add_vertex(v3)
