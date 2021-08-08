tool
extends Spatial

export (NodePath) var hip_node_path 
export (NodePath) var toe_node_path

onready var hip_node = get_node(hip_node_path)
onready var toe_node = get_node(toe_node_path)

export var length_hip := 0.5 setget set_length_hip
export var length_thigh := 0.5 setget set_length_thigh
export var length_shin := 1.25 setget set_length_shin

export var bone_width = 0.08 setget set_bone_width
export var bone_depth = 0.02 setget set_bone_depth

export var flipped = true

export var a_off := 0.43255
export var a_m := 1.0


const MIN_DIST = 0.25

var global_time = 0.0
onready var toe_initial_position = toe_node.transform.origin

var noise1 = OpenSimplexNoise.new()



func _ready():
	#yield(get_tree().create_timer(.1), "timeout")
	_set_bone_polygons(bone_width)
	_set_joint_positions()

	# Configure
	noise1.seed = randi()
	noise1.octaves = 4
	noise1.period = 30.0
	noise1.persistence = 0.8



func _process(delta):
	global_transform.origin = hip_node.global_transform.origin
	global_time += delta
	#var gt = hip_node.global_transform.origin
	var gx = global_transform.origin.x
	var gtx = toe_node.global_transform.origin.x
	var gz = global_transform.origin.z
	var gtz = toe_node.global_transform.origin.z
	var theta = atan2(gx - gtx, gz - gtz)
	set_rotation(Vector3(0, theta + PI/2.0, 0))
	
	var _x = Vector2(gx - gtx, gz - gtz).length()
	var _y = global_transform.origin.y - toe_node.global_transform.origin.y

	update_ik( Vector2(_x, _y), Vector2(0,0) )

	if not Engine.editor_hint:
		var a_x = toe_initial_position.x  + (sin((global_time + a_off)*a_m*8) * 0.25 + noise1.get_noise_2d(1.0,global_time*30) * 0.35)
		var a_z = toe_initial_position.z + cos((global_time + a_off)*a_m*8)*0.25 + noise1.get_noise_2d(1.0,(global_time*30)+100) * 0.35
		toe_node.transform.origin =Vector3(a_x, 0.0, a_z)

#-------------
# IK
#-------------
func update_ik(target_pos:Vector2, root_pos:Vector2) -> void:
	var offset = target_pos - root_pos
	var distance_to_target = offset.length()
	if distance_to_target < MIN_DIST:
		offset = (offset / distance_to_target ) * MIN_DIST
		distance_to_target = MIN_DIST

	var base_r = offset.angle()
	var len_total = length_hip + length_thigh + length_shin
	var len_dummy_side = (length_hip + length_thigh ) * clamp(distance_to_target/len_total, 0.0, 1.0) 

	# reverse ankle
	var base_angles = SSS_calc( len_dummy_side, length_shin, distance_to_target )
	var next_angles = SSS_calc( length_hip, length_thigh, len_dummy_side )
	$hip_joint.transform.basis = Basis(Vector3(0,0,1), -1*(base_angles.B - next_angles.B + base_r ) )
	$hip_joint/thigh_joint.transform.basis = Basis(Vector3(0,0,1), next_angles.C )
	$hip_joint/thigh_joint/shin_joint.transform.basis = Basis(Vector3(0,0,1) , -1*(base_angles.C - next_angles.A) )


func SSS_calc(side_a, side_b, side_c):
	if side_c >= side_a + side_b:
		return {"A": 0, "B": 0, "C": 0}
	var angle_a = law_of_cos(side_b, side_c, side_a)
	var angle_b = law_of_cos(side_c, side_a, side_b) + PI
	var angle_c = PI - angle_a - angle_b
 
	if flipped:
		angle_a = -angle_a
		angle_b = -angle_b
		angle_c = -angle_c
 
	return {"A": angle_a, "B": angle_b, "C": angle_c}


func law_of_cos(a, b, c):
	if 2 * a * b == 0:
		return 0
	return acos( (a * a + b * b - c * c) / ( 2 * a * b) )


#-------------
# UTIL
#-------------
func set_bone_width(new) -> void:
	bone_width = new
	if Engine.editor_hint:
		_set_bone_polygons(new)


func set_bone_depth(new) -> void:
	bone_depth = new
	if Engine.editor_hint:
		_set_bone_polygons(bone_width)
	

func set_length_hip(new) -> void:
	length_hip = new
	if Engine.editor_hint:
		_set_bone_polygons(bone_width)
		_set_joint_positions()


func set_length_thigh(new) -> void:
	length_thigh = new
	if Engine.editor_hint:
		_set_bone_polygons(bone_width)
		_set_joint_positions()


func set_length_shin(new) -> void:
	length_shin = new
	if Engine.editor_hint:
		_set_bone_polygons(bone_width)
		_set_joint_positions()


func _create_polygon(width: float = 1.0, length: float = 1.0) -> PoolVector2Array:
	return  PoolVector2Array([Vector2(0.0, width), Vector2(0.0, -width), Vector2(length, 0.0)])


func _set_bone_polygons(new_width) -> void:
	$hip_joint/polygon.polygon = _create_polygon(new_width, length_hip )
	$hip_joint/polygon.depth = bone_depth
	$hip_joint/polygon.transform.origin.z =  $hip_joint/polygon.depth / 2.0
	$hip_joint/thigh_joint/polygon.polygon = _create_polygon(new_width, length_thigh )
	$hip_joint/thigh_joint/polygon.depth = bone_depth
	$hip_joint/thigh_joint/polygon.transform.origin.z = $hip_joint/thigh_joint/polygon.depth / 2.0
	$hip_joint/thigh_joint/shin_joint/polygon.polygon = _create_polygon(new_width, length_shin )
	$hip_joint/thigh_joint/shin_joint/polygon.depth = bone_depth
	$hip_joint/thigh_joint/shin_joint/polygon.transform.origin.z = $hip_joint/thigh_joint/shin_joint/polygon.depth / 2.0


func _set_joint_positions() -> void:
	$hip_joint/thigh_joint.transform.origin.x = length_hip
	$hip_joint/thigh_joint/shin_joint.transform.origin.x = length_thigh

