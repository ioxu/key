extends Node

signal new_game_selected


func _ready():
	pass


func _process(delta):
	pass


func _on_quit_button_pressed():
	Game.quit()


func _on_new_game_button_pressed():
	pprint("start new game ..")
	$Control.set_visible(false)
	
#	$"../SubViewportContainer/SubViewport".set_input_as_handled()
#	get_viewport().set_input_as_handled()

	emit_signal("new_game_selected")


func pprint(thing) -> void:
	#print("[player] %s"%str(thing))
	print_rich("[code][b][color=Lightseagreen][ui_starting_menu][/color][/b][/code] %s" %str(thing))


