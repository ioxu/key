extends Area

signal bullet_hit


func _ready():
	pass # Replace with function body.


func bullet_hit(bullet):
	print("bullet_hit ", bullet.get_path(), " ", self.get_path())
	emit_signal("bullet_hit", bullet)
