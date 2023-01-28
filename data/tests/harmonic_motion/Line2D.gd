extends Line2D

var point


func _process(delta):
	point = get_node("../Sprite2D").global_position
	add_point(point)
	#print(get_point_count())
	if get_point_count() > 1600:
		#for i in range(100-get_point_count()):
		remove_point( 0 )
