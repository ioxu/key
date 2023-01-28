@tool
extends MeshInstance3D
class_name LineRenderer
#https://github.com/godotengine/godot-docs/issues/5901
#https://docs.godotengine.org/en/latest/classes/class_immediatemesh.html


#extends ImmediateMesh # TODO: no longer exists in G4, ImmediateMesh is now a Resource type

#@export_node_path(Camera3D) var camera 
@export var points = [Vector3(0,0,0),Vector3(0,5,0)]
@export var startThickness = 0.1
@export var endThickness = 0.1
@export var cornerSmooth = 5
@export var capSmooth = 5
@export var drawCaps = true
@export var drawCorners = true
@export var globalCoords = true
@export var scaleTexture = true

var camera
var cameraOrigin


#var material: StandardMaterial3D = StandardMaterial3D.new()

func _ready():
	mesh = ImmediateMesh.new()
#	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
#	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
#	set_material_override(material)
#	if camera.is_empty():
#		camera = null
#	else:
#		camera = get_node(camera)


func _process(_delta):
	if not self.visible:
		return

	if points.size() < 2:
		return

	#print("[line_renderer] camera NodePath: %s"%camera)

	camera = get_viewport().get_camera_3d()

	if camera == null:
		cameraOrigin = Vector3.BACK * 20.0
	else:
		cameraOrigin = to_local(camera.get_global_transform().origin)
	#print("[line_renderer] camera origin: %s"%cameraOrigin)

	mesh.clear_surfaces()

	var progressStep = 1.0 / points.size();
	var progress = 0;
	var thickness = lerp(startThickness, endThickness, progress);
	var nextThickness = lerp(startThickness, endThickness, progress + progressStep);



#	#prints("drawing ImmediateMesh", self.get_path())
#	if not self.visible:
#		return
#
##	if not Engine.is_editor_hint():
##		prints("# LINE_RENDERER._process ", self.get_name())
#
#	if points.size() < 2:
#		return
#
#	#camera = get_node( camera ) #get_viewport().get_camera_3d()
#	if camera == null:
#		return
#	cameraOrigin = to_local(camera.get_global_transform().origin)
#
#	var progressStep = 1.0 / points.size();
#	var progress = 0;
#	var thickness = lerp(startThickness, endThickness, progress);
#	var nextThickness = lerp(startThickness, endThickness, progress + progressStep);
#
#	clear()
#	begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh.surface_begin( Mesh.PRIMITIVE_TRIANGLES )

	for i in range(points.size() - 1):
		var A = points[i]
		var B = points[i+1]
#
		if globalCoords:
			A = to_local(A)
			B = to_local(B)
#
		var V1 = i * progressStep
		var V2 = (i+1) * progressStep
#
		var AB = B - A;
		var orthogonalABStart = (cameraOrigin - ((A + B) / 2)).cross(AB).normalized() * thickness;
		var orthogonalABEnd = (cameraOrigin - ((A + B) / 2)).cross(AB).normalized() * nextThickness;
#
		var AtoABStart = A + orthogonalABStart
		var AfromABStart = A - orthogonalABStart
		var BtoABEnd = B + orthogonalABEnd
		var BfromABEnd = B - orthogonalABEnd
#
		if i == 0:
			if drawCaps:
				cap(A, B, thickness, capSmooth)

		if scaleTexture:
			var ABLen = AB.length()
			var ABFloor = floor(ABLen)
			var ABFrac = ABLen - ABFloor

			mesh.surface_set_uv(Vector2(ABFloor, 0))
			mesh.surface_add_vertex(AtoABStart)
			mesh.surface_set_uv(Vector2(-ABFrac, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(ABFloor, 1))
			mesh.surface_add_vertex(AfromABStart)
			mesh.surface_set_uv(Vector2(-ABFrac, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(-ABFrac, 1))
			mesh.surface_add_vertex(BfromABEnd)
			mesh.surface_set_uv(Vector2(ABFloor, 1))
			mesh.surface_add_vertex(AfromABStart)
		else:
#			mesh.surface_set_uv(Vector2(1, 0))
#			mesh.surface_add_vertex(AtoABStart)
#			mesh.surface_set_uv(Vector2(0, 0))
#			mesh.surface_add_vertex(BtoABEnd)
#			mesh.surface_set_uv(Vector2(1, 1))
#			mesh.surface_add_vertex(AfromABStart)
#			mesh.surface_set_uv(Vector2(0, 0))
#			mesh.surface_add_vertex(BtoABEnd)
#			mesh.surface_set_uv(Vector2(0, 1))
#			mesh.surface_add_vertex(BfromABEnd)
#			mesh.surface_set_uv(Vector2(1, 1))
#			mesh.surface_add_vertex(AfromABStart)

			mesh.surface_set_uv(Vector2(V1, 0))
			mesh.surface_add_vertex(AtoABStart)
			mesh.surface_set_uv(Vector2(V2, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(V1, 1))
			mesh.surface_add_vertex(AfromABStart)
			mesh.surface_set_uv(Vector2(V2, 0))
			mesh.surface_add_vertex(BtoABEnd)
			mesh.surface_set_uv(Vector2(V2, 1))
			mesh.surface_add_vertex(BfromABEnd)
			mesh.surface_set_uv(Vector2(V1, 1))
			mesh.surface_add_vertex(AfromABStart)

		if i == points.size() - 2:
			if drawCaps:
				cap(B, A, nextThickness, capSmooth)
		else:
			if drawCorners:
				var C = points[i+2]
				if globalCoords:
					C = to_local(C)

				var BC = C - B;
				var orthogonalBCStart = (cameraOrigin - ((B + C) / 2)).cross(BC).normalized() * nextThickness;

				var angleDot = AB.dot(orthogonalBCStart)

				if angleDot > 0:
					corner(B, BtoABEnd, B + orthogonalBCStart, cornerSmooth)
				else:
					corner(B, B - orthogonalBCStart, BfromABEnd, cornerSmooth)

		progress += progressStep;
		thickness = lerp(startThickness, endThickness, progress);
		nextThickness = lerp(startThickness, endThickness, progress + progressStep);

	mesh.surface_end()


func cap(center, pivot, thickness, smoothing):
#	pass
	var orthogonal = (cameraOrigin - center).cross(center - pivot).normalized() * thickness;
	var axis = (center - cameraOrigin).normalized();

	var array = []
	for _i in range(smoothing + 1):
		array.append(Vector3(0,0,0))
	array[0] = center + orthogonal;
	array[smoothing] = center - orthogonal;

	for i in range(1, smoothing):
		array[i] = center + (orthogonal.rotated(axis, lerp(0.0, PI, float(i) / float(smoothing) ) ) );

	for i in range(1, smoothing + 1):
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i - 1]);
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i]);
		mesh.surface_set_uv(Vector2(0.5, 0.5))
		mesh.surface_add_vertex(center);


func corner(center, start, end, smoothing):
#	pass
	var array = []
	for _i in range(smoothing + 1):
		array.append(Vector3(0,0,0))
	array[0] = start;
	array[smoothing] = end;

	var axis = start.cross(end).normalized()
	var offset = start - center
	var angle = offset.angle_to(end - center)

	for i in range(1, smoothing):
		#prints("### AXIS ", axis.normalized(), " ", self.get_path())
		array[i] = center + offset.rotated(axis.normalized(), lerp(0.0, angle, float(i) / float(smoothing) ) );

	for i in range(1, smoothing + 1):
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i - 1]);
		mesh.surface_set_uv(Vector2(0, (i - 1) / smoothing))
		mesh.surface_add_vertex(array[i]);
		mesh.surface_set_uv(Vector2(0.5, 0.5))
		mesh.surface_add_vertex(center);

