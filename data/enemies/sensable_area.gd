extends Area

export(NodePath) var sibling_sensing_area

func _ready():
	sibling_sensing_area = get_node( sibling_sensing_area )


func _on_sensable_area_area_entered(area):
	if is_valid_area(area):
		print(self.get_path(), " area entered ", area.get_path())
		# connect signals


func _on_sensable_area_area_exited(area):
	if is_valid_area(area):
		print(self.get_path(), " area exited ", area.get_path())
		# disconnect signals


func is_valid_area(area):
	return area.is_in_group("npc_sensing_area") and area != sibling_sensing_area


