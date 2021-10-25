extends Spatial

var tracked_enemies = []
var enemy_dots = []
var tracked_doors = []


onready var arch_radar_dot = get_node("radar_dot")
var dot_pos_radius := 0.0
var dot_scale := 1.0
onready var dot_scene = preload("res://scenes/player/radar_dot.tscn")

const VFLATTEN = Vector3(1.0, 0.0, 1.0)

func _ready():
	dot_pos_radius = arch_radar_dot.transform.origin.length()
	dot_scale = arch_radar_dot.transform.basis.x.length()

	$radar_dot.queue_free()

	for _i in range(20):
		var d = dot_scene.instance()
		self.add_child(d)
		d.set_scale(Vector3.ONE * dot_scale)
		d.visible = false
		enemy_dots.append( d )


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


func _on_Area_body_entered(body):
	if body.is_in_group("Enemies"):
		tracked_enemies.append( body )


func _on_Area_body_exited(body):
	if body.is_in_group("Enemies"):
		tracked_enemies.erase( body )

