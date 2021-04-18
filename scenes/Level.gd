extends Spatial
class_name Level

export var level_name := ""

func _ready():
	prints("Level ready", self.get_path(), self.level_name)
#	Game.set_level(get_tree().get_current_scene())
#	Game.set_player(Game.level.find_node("player"))
	Game.level_ready( self )
