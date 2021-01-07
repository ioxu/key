extends Label


func _ready():
	pass # Replace with function body.


func _process(delta):
	self.text = "fps " + str(Engine.get_frames_per_second())
