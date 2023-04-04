extends Node3D
class_name TrailRenderer

# thank you IndieQuest!
# originally https://github.com/IndieQuest/DogFightTutorial/blob/master/TrailRenderScriptClass/TrailRender.gd

#############################
# EXPORT PARAMS
#############################
# width
@export var width: float = 0.5
@export var width_curve: Curve
@export_node_path("Node3D") var rotation_constrain
# length
@export var max_points := 100
@export var material: Material
# show or hide
@export var render: bool = true


#############################
# PARAMS
#############################
@onready var half_width = width * 0.5
var points := []


var life_frames : = 0


#############################
# OVERRIDE FUNCTIONS
#############################
func _ready() -> void:
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
	if render:
		# add new point and render
		if life_frames%2 == 0 :
			add_point()
		else:
			first_point()
		_draw_trail()
	else:
		# slowly hide the trail
		if points.size() > 0:
			var last_point = points.pop_back()
			last_point.queue_free()


#############################
# API
#############################
func first_point() -> void:
	if points.size() > 1:
		#var new_point = Marker3D.new()
		var new_point = Transform3D()
		#new_point.global_position = self.global_transform.origin
		new_point.origin = self.global_transform.origin
		if rotation_constrain:
			#new_point.rotation = rotation_constrain.global_transform.basis.get_euler()
			new_point.basis = rotation_constrain.global_transform.basis
		else:
			#new_point.rotation = self.global_transform.basis.get_euler()
			new_point.basis = self.global_transform.basis
		
		points[0] = new_point


func add_point() -> void:
	#var new_point = Marker3D.new()
	var new_point = Transform3D()
	#new_point.global_position = self.global_transform.origin
	new_point.origin = self.global_transform.origin
	if rotation_constrain:
		#new_point.rotation = rotation_constrain.global_transform.basis.get_euler()
		new_point.basis = rotation_constrain.global_transform.basis
	else:
		#new_point.rotation = self.global_transform.basis.get_euler()
		new_point.basis = self.global_trasnform.basis
	points.insert(0, new_point)
	if points.size() > max_points:
		var last_point = points.pop_back()
		#last_point.queue_free()


func _draw_trail() -> void:
	if points.size() < 2:
		return
	# create surface tool
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# draw triangles
	for i in range(points.size() - 1):
		_points_to_rect(st, points[i], points[i + 1], i)
	# commit
	st.generate_normals()
#	st.generate_tangents()
	$Node/Render.mesh = st.commit()
	$Node/Render.set_surface_override_material(0, material) #set_surface_material(0, material)


#func _points_to_rect(st: SurfaceTool, p1: Marker3D, p2: Marker3D, idx: float) -> void:
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
