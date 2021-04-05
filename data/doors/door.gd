extends Area

export(String) var door_name
export(String, FILE, "*.tscn,*.scn") var connects_to_scene
export(String) var connects_to_door

func _ready():
	pass


func _on_door_body_entered(body):
	prints("door.body_entered", self.get_path(), body.get_path())
	# tell game.gd to switch scenes
