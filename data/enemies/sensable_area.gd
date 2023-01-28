extends Area3D

@export_node_path var sibling_sensing_area#: Area3D#NodePath
@export_node_path var parent_npc #NodePath

func _ready():
	sibling_sensing_area = get_node( sibling_sensing_area )
	parent_npc = get_node(parent_npc)
	pass

func _on_sensable_area_area_entered(area):
	if is_valid_area(area):
		#print(self.get_path(), " area entered ", area.get_path())
		parent_npc.connect("notify_allies",Callable(area.parent_npc,"_on_ally_notification"))


func _on_sensable_area_area_exited(area):
	if is_valid_area(area):
		#print(self.get_path(), " area exited ", area.get_path())
		parent_npc.disconnect("notify_allies",Callable(area.parent_npc,"_on_ally_notification"))


func is_valid_area(area):
	return area.is_in_group("npc_sensing_area") and area != sibling_sensing_area


