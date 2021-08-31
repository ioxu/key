extends Line2D

var point


func _process(delta):
	point = get_node("../Sprite").global_position
	add_point(point)
	
