extends Area3D

class_name door

@export var door_name: String
@export_file("*.tscn *.scn") var connected_scene# : (String, FILE, "*.tscn,*.scn")
@export var connected_door: String

@onready var label = $Label3D


func _ready():
#	label.text = "name: "+ door_name + "\n"\
#			+ "scene: "+ connected_scene + "\n"\
#			+ "connnected door: " + connected_door
	label.text = "name: %s\nscene: %s\nconnected door: %s"%[door_name, connected_scene, connected_door]
	print("[door] name: %s"%door_name)
	print("[door] scene: %s"%connected_scene)
	print("[door] connected door: %s"%connected_door)


func _on_door_body_entered(body) -> void:
	if body.is_in_group("Player"):
		prints("door.body_entered", self.get_path(), body.get_path())

		# tell game.gd to switch scenes
		if self.connected_scene != "" or self.connected_scene != null:
			Game.enter_door(self.door_name, self.connected_scene, self.connected_door )


func get_class_name() -> String:
	return "door"
