extends Area

class_name door

export(String) var door_name
export(String, FILE, "*.tscn,*.scn") var connected_scene
export(String) var connected_door

onready var label = $Label3D

func _ready():
	label.text = "name: "+ door_name + "\n"\
			 + "scene: "+ connected_scene + "\n"\
			 + "connnected door: " + connected_door


func _on_door_body_entered(body):
	if body.is_in_group("Player"):
		prints("door.body_entered", self.get_path(), body.get_path())

		# tell game.gd to switch scenes
		if self.connected_scene != "":
			Game.enter_door(self.door_name, self.connected_scene, self.connected_door )


func get_class():
	return "door"
