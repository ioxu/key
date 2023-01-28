extends RayCast3D

var target = null

@onready var timer = $routine_check

var sight_line = null
const sight_line_script = preload("res://data/scripts/sight_line.gd")

var running = false
var from := Vector3.ZERO
var to := Vector3.ZERO

var can_see_target = false

var is_hidden_at_start = false # so if the node is hidden at the start (by the gui)
								# never become visible

func _ready():
	exclude_parent = true

	sight_line = MeshInstance3D.new()#ImmediateMesh.new()
	sight_line.set_script(sight_line_script)
	#get_node("/root/").add_child(sight_line)
	get_tree().get_root().add_child(sight_line)

	if !running:
		stop()

	if !visible:
		is_hidden_at_start = true


func _is_target_visible():
	if target and target.targetable:
		from = get_owner().global_transform.origin
		to = target.global_transform.origin
		to = Vector3(to.x, from.y, to.z)
		#pprint("to: %s"%to)
		#cast_to = to_local(to).normalized() * 15.0
		target_position = to_local(to).normalized() * 15.0
		if is_colliding():
			#pprint(" -> colliding")
			var collider = get_collider()
			if collider and collider.is_in_group("Player"):
				$sight_indicator.transform.origin = to_local(get_collision_point())
				can_see_target = true
			else:
				$sight_indicator.transform.origin = to_local(get_collision_point())#Vector3(0.0, 0.0, -1.0)
				can_see_target = false
			if !is_hidden_at_start:
				sight_line.visible = true
			sight_line.from = from
			sight_line.to = get_collision_point()


func start():
	_is_target_visible()
	timer.start()
	running = true
	enabled = true


func stop():
	timer.stop()
	running = false
	enabled = false
	$sight_indicator.transform.origin = Vector3.ZERO
	can_see_target = false
	sight_line.visible = false


func _on_routine_check_timeout():
	_is_target_visible()
	if !running:
		stop()


func pprint(thing) -> void:
	print("[vision_raycast] %s"%str(thing))
