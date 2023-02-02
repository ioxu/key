extends Node


func _ready():
	pprint("TEMPORARY: set TextureRect to ../SubViewportContainer/SubViewport")
	$TextureRect.texture = $"../SubViewportContainer/SubViewport".get_texture()


func _process(delta):
	pass


func pprint(thing) -> void:
	print("[ViewportDisplay] %s"%str(thing))
