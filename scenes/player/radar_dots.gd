extends Node3D

var tracked_enemies = []
var enemy_dots = []
var tracked_doors = []
var door_dots = []

@onready var arch_radar_dot = get_node("radar_dot")
var dot_pos_radius := 0.0
var dot_scale := 1.0
@onready var dot_enemy_scene = preload("res://scenes/player/radar_dot.tscn")
@onready var dot_door_scene = preload("res://scenes/player/radar_door_dot.tscn")

const VFLATTEN = Vector3(1.0, 0.0, 1.0)

func _ready():
	dot_pos_radius = arch_radar_dot.transform.origin.length()
	dot_scale = arch_radar_dot.transform.basis.x.length()

	$radar_dot.queue_free()

	for _i in range(20):
		var d = dot_enemy_scene.instantiate()
		self.add_child(d)
		d.set_scale(Vector3.ONE * dot_scale)
		d.visible = false
		enemy_dots.append( d )
		
	for _i in range(5):
		var d = dot_door_scene.instantiate()
		self.add_child(d)
		d.set_scale(Vector3.ONE * dot_scale)
		d.visible = false
		door_dots.append( d )
		

func _process(delta) -> void:
	if self.visible == false:
		return

	for i in range(enemy_dots.size() -1 ):
		if i >= (tracked_enemies.size() -1) :
			enemy_dots[i].visible = false
		if tracked_enemies.size() <= i:
			break
		var eo = tracked_enemies[i].global_transform.origin * VFLATTEN
		var so = self.global_transform.origin * VFLATTEN
		var t =  eo - so
		enemy_dots[i].transform.origin = t.normalized() * dot_pos_radius
		enemy_dots[i].visible = true
		
	for i in range(door_dots.size() -1):

		if i >= (tracked_doors.size() -1) :
			door_dots[i].visible = false
		if tracked_doors.size() <= i:
			break
		var eo = tracked_doors[i].global_transform.origin * VFLATTEN
		var so = self.global_transform.origin * VFLATTEN
		var t =  eo - so
		door_dots[i].transform.origin = t.normalized() * dot_pos_radius
		door_dots[i].visible = true


func _on_Area_body_entered(body):
	if body.is_in_group("Enemies"):
		tracked_enemies.append( body )


func _on_Area_body_exited(body):
	if body.is_in_group("Enemies"):
		tracked_enemies.erase( body )


func _on_Area_area_entered(area):
	pprint("area entered: %s"%area)
	if area.is_in_group("Doors"):
		tracked_doors.append( area )


func _on_Area_area_exited(area):
	if area.is_in_group("Doors"):
		tracked_doors.erase( area )


func pprint(thing) -> void:
	print("[radar_dots] %s"%str(thing))
