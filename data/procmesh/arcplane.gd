tool
extends MeshInstance
# arcplane ArrayMesh script
# add this script to a MeshInstance node,
# and set its mesh to an ArrayMesh

export(int, 1, 64) var rings = 5 setget set_rings
export(int, 1, 256) var radial_segments = 20 setget set_radial_segments
export var height = 1.0 setget set_height
export var radius = 3.25 setget set_radius
export var zenith_min = 0.45 setget set_zenith_min
export var zenith_max = 0.65 setget set_zenith_max
export(float, 0.0, 1.0) var arc_length = 0.5 setget set_arc_length
export(float, -1.0, 1.0) var arc_offset = 0.0 setget set_arc_offset

export(bool) var join_radial = false setget set_join_radial
export(bool) var normalise_UVs = true setget set_normalise_UVs
export(bool) var flip_u = false setget set_flip_u
export(bool) var flip_v = false setget set_flip_v

func _ready():
	generate_mesh()


func generate_mesh() -> void:
	mesh.clear_surfaces()
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()

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

