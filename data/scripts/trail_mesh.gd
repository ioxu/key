extends Node3D
class_name TrailRenderer

# thank you IndieQuest!
# originally https://github.com/IndieQuest/DogFightTutorial/blob/master/TrailRenderScriptClass/TrailRender.gd

# width
@export var age_speed: float = 0.25
@export var width: float = 0.5
@export var width_curve: Curve
@export_node_path("Node3D") var rotation_constrain

# subdivision
@export var time_interval_to_add_point : float = 2.0 #0.05
var _time_since_last_point := 0.0

@export var distance_step = 2.0
var _distance_since_last_point := 0.0

@export var max_points := 100
@export var material: Material
# show or hide
@export var render: bool = true
@export var draw_debug: bool = true

@onready var half_width = width * 0.5
var points := [] # Transform3D
var point_directions := [] # Vector3
var point_curls := [] # floats - dot product of this direction and last direction
var point_curl_signs := []	# floats - the sign of the y value of the cross product of this dirction
							# and last direction, to determine the outsideness of the curl
var point_bitangents := [] # Vector3
var speeds := [] # floats
var ages := [] # floats

var life_frames : = 0
var life_time : = 0.0

var surfacetool : SurfaceTool

var immeditateMesh : ImmediateMesh
var immeditateMeshLines : ImmediateMesh
var debugLinesColour := Color(0, 0.97647058963776, 0.3647058904171, 0.54509806632996)
var debugLinesColour_bitangent := Color(0.98000001907349, 0.23520001769066, 0.23520001769066)
var debugLinesColour_forward := Color(0.23520001769066, 0.2972666323185, 0.98000001907349, 0.75686275959015)

var stats = {
	max_speed = 0.0,
}

var this_process_point_position : Vector3
var point_dir : Vector3
var last_process_point_position : Vector3
var last_direction : Vector3
var point_curl : float
var point_curl_sign : float
var point_bitangent : Vector3

var last_point_position : Vector3

var main_timer : Timer
var main_timer_count := 0


func _ready() -> void:
	
	main_timer = Timer.new()
	main_timer.wait_time = 0.03
	main_timer.autostart = self.render
	main_timer.connect("timeout", self._on_main_timer_timeout)
	self.add_child(main_timer)


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

	var debugMesh = MeshInstance3D.new()
	debugMesh.name = "Debug"
	node.add_child(debugMesh)
	immeditateMesh = ImmediateMesh.new()
	
	var debugMeshLines = MeshInstance3D.new()
	debugMeshLines.name = "DebugLines"
	node.add_child(debugMeshLines)
	immeditateMeshLines = ImmediateMesh.new()
	
	
	var debugMaterial = StandardMaterial3D.new()
	debugMaterial.vertex_color_use_as_albedo = true
	debugMaterial.set_shading_mode( BaseMaterial3D.SHADING_MODE_UNSHADED )
	debugMaterial.use_point_size = true
	debugMaterial.point_size = 2.5
	debugMaterial.no_depth_test = true
	
	debugMesh.mesh = immeditateMesh
	debugMesh.material_override = debugMaterial

	var debugLinesMaterial = StandardMaterial3D.new()
	debugLinesMaterial.vertex_color_use_as_albedo = true
	debugLinesMaterial.set_shading_mode( BaseMaterial3D.SHADING_MODE_UNSHADED )
	debugLinesMaterial.no_depth_test = true
	debugLinesMaterial.set_transparency( BaseMaterial3D.TRANSPARENCY_ALPHA )
	
	debugMeshLines.mesh = immeditateMeshLines
	debugMeshLines.material_override = debugLinesMaterial

	add_point()

	last_point_position = self.global_transform.origin


func _on_main_timer_timeout() -> void:
	#print("   .. TrailRenderer: main_timer %s (%0.2f)"%[ main_timer_count ,life_time] )
	add_point()

func _physics_process(delta):
#	if render:
#
#		# gather max velocity
#		var this_point_position := self.global_transform.origin
#		var speed = (this_point_position - last_point_position).length() * (1.0/delta)
#		if stats.max_speed < speed:
#			stats.max_speed = speed
#		last_point_position = this_point_position
#		#print("    max_speed %0.5f"%stats.max_speed)
	pass

func _process(delta: float) -> void:
	life_frames+=1
	life_time += delta
	if render:

		# add new point and render

#		var this_process_point_position := self.global_transform.origin

#		if _time_since_last_point >= time_interval_to_add_point or\
#					_distance_since_last_point >= distance_step:
#
#			# calc point data
#
#			point_dir = this_process_point_position - last_process_point_position #last_point_position - this_point_position
#
#			point_curl = point_dir.normalized().dot( last_direction.normalized() )
#
#			point_curl_sign = sign(last_direction.normalized().cross( point_dir.normalized() ).y) #sign(point_dir.normalized().cross( last_direction.normalized() ).y)
#
#			point_bitangent = point_dir.normalized().cross(Vector3.UP)
#
#
#
#			# capture point data
#			add_point()
#			_time_since_last_point = 0.0
#			_distance_since_last_point = 0.0
#			last_process_point_position = this_process_point_position
#			last_direction = point_dir
#
#		else:
#			first_point()



		_draw_trail()
		_time_since_last_point +=delta
		
		if points.size() >= 2:
			# measure distance from last point
			_distance_since_last_point += (self.global_transform.origin - points[1].origin).length()
			#print("_distance_since_last_point %.3f"%_distance_since_last_point)


		immeditateMesh.clear_surfaces()
		#immeditateMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP )
		immeditateMesh.surface_begin(Mesh.PRIMITIVE_POINTS )

		immeditateMeshLines.clear_surfaces()
		immeditateMeshLines.surface_begin(Mesh.PRIMITIVE_LINES)

		var ppos : Vector3
		var ppos_age : Vector3
		# loop points
		
		for i in range(points.size() - 1):
			# decrement ages
			ages[i] = ages[i] - delta * age_speed

			if draw_debug:
				ppos = points[i].origin
				immeditateMesh.surface_set_color ( Color(0.75486749410629, 0.13044109940529, 0.37367144227028) )
				immeditateMesh.surface_add_vertex( ppos ) #+ Vector3.UP * 2.0 )

				immeditateMeshLines.surface_set_color ( Color(0.16470588743687, 1, 0.34509804844856, 0.04313725605607) )
				immeditateMeshLines.surface_add_vertex( ppos )
				immeditateMeshLines.surface_add_vertex( ppos + point_directions[i].normalized() )

	#			immeditateMeshLines.surface_set_color ( Color(0.79607844352722, 0.27058824896812, 0.52941179275513, 0.43137255311012) )
	#			immeditateMeshLines.surface_add_vertex( ppos )
	#			immeditateMeshLines.surface_add_vertex( ppos + point_bitangents[i].normalized() * 0.25 )

				# curl sprays
				var _c = Color(0.5975775718689, 0.60273468494415, 0.28934633731842, 0.74901962280273)
				immeditateMeshLines.surface_set_color ( _c )
				immeditateMeshLines.surface_add_vertex( ppos )
				var _ppc = point_bitangents[i]#.normalized() 
				_ppc *= (1.0 - pow(1.0 - Util.circ( 1.0 - point_curls[i] ), 1.5) )
				_ppc *= 3.0 * point_curl_signs[i]
				immeditateMeshLines.surface_set_color ( _c * Color(1, 1, 1, 0.05) )
				immeditateMeshLines.surface_add_vertex( ppos + _ppc )


	#			# age line
	##			ppos_age = points[i].origin + Vector3.UP * ages[i] * 10.0
	##			if ppos.y < ppos_age.y:
	##				immeditateMesh.surface_set_color ( debugLinesColour )
	##				immeditateMeshLines.surface_add_vertex( ppos )
	##				immeditateMeshLines.surface_add_vertex( ppos_age )
	#
	#
	##			immeditateMeshLines.surface_set_color ( debugLinesColour )
	##			immeditateMeshLines.surface_add_vertex( ppos )
	##			immeditateMeshLines.surface_add_vertex( ppos + Vector3.UP * speeds[i] * 0.25 )
	#
	#			immeditateMeshLines.surface_set_color( debugLinesColour_bitangent)
	#			#immeditateMeshLines.surface_add_vertex( ppos )
	#
	#			var pointdir = (points[i].origin - points[i+1].origin).normalized()
	#			var prev_pointdir = (points[i-1].origin - points[i].origin).normalized()
	#			var next_pointdir = (points[i+1].origin - points[min(i+2, points.size() - 1)].origin).normalized()
	#			var bit = pointdir.cross(Vector3.UP)
	#			var curl =  next_pointdir.cross( pointdir ) #pointdir.cross( prev_pointdir) #prev_pointdir )
	#			#var curl_amount = remap(pointdir.dot( next_pointdir ), 0.45, 1.0, 0.0, 1.0)
	#
	#			var curl_amount = pointdir.dot( next_pointdir ) #remap(pointdir.dot( next_pointdir ), 0.0, 1.0, 0.0, 1.0)
	#			#curl_amount = 1.0 - pow(clamp( curl_amount, 0.0, 1.0 ), 8)
	#			#curl_amount = Util.circ( 1.0 - curl_amount )
	#			curl_amount = clamp( curl_amount, 0.0, 1.0 )
	#
	#			curl_amount = 1.0 - pow( 1.0 - Util.circ(1.0-curl_amount), 1.5)
	#
	##			if i == 2:
	##				print("curl_amount %s"%curl_amount)
	#
	#			#curl_amount = Util.circ( 1.0 - curl_amount )
	#
	#			#immeditateMeshLines.surface_add_vertex( ppos + bit * signf(curl.y) * curl_amount ) #1.0 )
	#
	#			immeditateMeshLines.surface_set_color ( debugLinesColour )
	#			immeditateMeshLines.surface_add_vertex( ppos )
	#			if i == 2:
	#				print("speed: %s"%speeds[i])
	#			immeditateMeshLines.surface_add_vertex( ppos + bit * signf(curl.y) * curl_amount )# * speeds[i] * 0.2 )

		if draw_debug:
			immeditateMesh.surface_end()
			immeditateMeshLines.surface_end()

	else:
		# slowly hide the trail
		if points.size() > 0:
			var last_point = points.pop_back()
			#last_point.queue_free()


func first_point() -> void:
	if points.size() > 1:
		var new_point = Transform3D()
		new_point.origin = self.global_transform.origin
		if rotation_constrain:
			new_point.basis = rotation_constrain.global_transform.basis
		else:
			new_point.basis = self.global_transform.basis
		
		points[0] = new_point
		ages[0] = 1.0
		speeds[0] = stats.max_speed


func add_point() -> void:
	this_process_point_position = self.global_transform.origin

	####
	point_dir = this_process_point_position - last_process_point_position #last_point_position - this_point_position
	point_curl = point_dir.normalized().dot( last_direction.normalized() )
	point_curl_sign = sign(last_direction.normalized().cross( point_dir.normalized() ).y) #sign(point_dir.normalized().cross( last_direction.normalized() ).y)
	point_bitangent = point_dir.normalized().cross(Vector3.UP)
	####


	var new_point = Transform3D()
	new_point.origin = self.global_transform.origin
	if rotation_constrain:
		new_point.basis = rotation_constrain.global_transform.basis
	else:
		new_point.basis = self.global_transform.basis
	points.insert(0, new_point)
	point_directions.insert(0, point_dir)
	point_curls.insert(0, point_curl)
	point_curl_signs.insert(0, point_curl_sign)
	point_bitangents.insert(0, point_bitangent)
	ages.insert(0, 1.0)
	speeds.insert(0, stats.max_speed)
	stats.max_speed = 0.0
	
	if points.size() > max_points:
		var last_point = points.pop_back()
		point_directions.pop_back()
		ages.pop_back()
		speeds.pop_back()

	####
	_time_since_last_point = 0.0
	_distance_since_last_point = 0.0
	last_process_point_position = this_process_point_position
	last_direction = point_dir
	####


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
