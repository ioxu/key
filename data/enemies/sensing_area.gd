extends Area

export(NodePath) var parent_npc


func _ready():
	parent_npc = get_node(parent_npc)

