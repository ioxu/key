extends RayCast

var target = null

onready var timer = $routine_check

var running = false
var from := Vector3.ZERO
var to := Vector3.ZERO

var can_see_target = false


func _ready():
	if !running:
		stop()
	exclude_parent = true


func _is_target_visible():
	if target:
		from = get_owner().global_transform.origin
		to = target.global_transform.origin
		to = Vector3(to.x, from.y, to.z)
		cast_to = to_local(to).normalized() * 15.0
		if is_colliding():
			var collider = get_collider()
			if collider.is_in_group("Player"):
				print("raycast can see")
				#$MeshInstance.transform.origin = to_local(get_collision_point())
				can_see_target = true
			else:
				#$MeshInstance.transform.origin = Vector3.ZERO
				can_see_target = false


func start():
	_is_target_visible()
	timer.start()
	running = true
	enabled = true



func stop():
	timer.stop()
	running = false
	enabled = false
	#$MeshInstance.transform.origin = Vector3.ZERO
	can_see_target = false


func _on_routine_check_timeout():
	#can_see_target = _is_target_visible()
	_is_target_visible()
	if !running:
		stop()
	
