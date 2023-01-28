extends Area3D

@export_node_path var parent_npc #: NodePath


func _ready():
	parent_npc = get_node(parent_npc)

