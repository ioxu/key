@tool
extends MeshInstance3D
# arcplane ArrayMesh script
# add this script to a MeshInstance3D node,
# and set its mesh to an ArrayMesh

@export var rings : int = 5 : set = set_rings # (int, 1, 64)
@export var radial_segments : int = 20 : set = set_radial_segments # (int, 1, 256)
@export var height = 1.0 : set = set_height
@export var radius = 3.25 : set = set_radius
@export var zenith_min = 0.45 : set = set_zenith_min
@export var zenith_max = 0.65 : set = set_zenith_max
@export var arc_length = 0.5 : set = set_arc_length # (float, 0.0, 1.0)
@export var arc_offset = 0.0 : set = set_arc_offset # (float, -1.0, 1.0)

@export var join_radial: bool = false : set = set_join_radial
@export var normalise_UVs: bool = true : set = set_normalise_UVs
@export var flip_u: bool = false : set = set_flip_u
@export var flip_v: bool = false : set = set_flip_v


func _ready():
	generate_mesh()


func _get_configuration_warnings():
	if not mesh or mesh.get_class() != "ArrayMesh":
		return 'mesh needs to be set to an ArrayMesh'
	return ''

func generate_mesh() -> void:
	if mesh.get_class() == "ArrayMesh":
		update_configuration_warnings()

	mesh.clear_surfaces()
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings+1):
		var v = lerp(zenith_min, zenith_max, float(i) / rings)
		var w = sin(PI * v)
		var y = cos(PI * v) * height

		# Loop over segments in ring.
		for j in range(radial_segments):
			var u = float(j) / (radial_segments-1)
			u *= arc_length
			u += arc_offset
			#u += PI
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = Vector3(x * radius * w, y, z * radius * w)
			verts.append(vert)
			normals.append(vert.normalized())

			if normalise_UVs:
				u = (float(j) / (radial_segments-1))
				v = 1.0 - (float(i) / rings)
			if flip_u:
				u = 1.0 - u
			if flip_v:
				v = 1.0 - v
			uvs.append(Vector2( u, v) )

			point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0 and j != radial_segments:
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		if join_radial and i > 0:
			# join with last radial segment
			indices.append(prevrow + radial_segments - 1)
			indices.append(prevrow)
			indices.append(thisrow + radial_segments - 1)

			indices.append(prevrow)
			indices.append(prevrow + radial_segments)
			indices.append(thisrow + radial_segments - 1)

		prevrow = thisrow
		thisrow = point


	# Assign arrays to mesh array.
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)


func set_rings(new_value)->void:
	rings = new_value
	generate_mesh()


func set_radial_segments(new_value)->void:
	radial_segments = new_value
	generate_mesh()


func set_height(new_value)->void:
	height = new_value
	generate_mesh()
	

func set_radius(new_value)->void:
	radius = new_value
	generate_mesh()


func set_zenith_min(new_value)-> void:
	zenith_min = new_value
	generate_mesh()


func set_zenith_max(new_value) -> void:
	zenith_max = new_value
	generate_mesh()


func set_join_radial(new_value) -> void:
	join_radial = new_value
	generate_mesh()


func set_arc_length(new_value) -> void:
	arc_length = new_value
	generate_mesh()


func set_arc_offset(new_value) -> void:
	arc_offset = new_value
	generate_mesh()


func set_normalise_UVs(new_value) -> void:
	normalise_UVs = new_value
	generate_mesh()


func set_flip_u(new_value) -> void:
	flip_u = new_value
	generate_mesh()


func set_flip_v(new_value) -> void:
	flip_v = new_value
	generate_mesh()

