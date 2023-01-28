extends Node2D

var label_opac_default = .2
var label_opac_focus = 1.0
var focus_owner = null
var last_focus_owner = null
var _current_menu = null
var _previous_menu = null
@onready var ANCHOR = $top_left_anchor


signal close_options_menu

signal toggle_SSAO(value)

# override ScrollContainer vertical scroll bar theme 
var vs_theme = preload("res://scenes/player/options_menu_vscrollbar_theme.tres")


func _ready():
	prints("options_menu_2d ready")
	# hide all menus, get labels
	var labels = []
	for m in get_tree().get_nodes_in_group("options_menu_group"):
		m.hide()
		
		for c in Util.get_all_children(m.get_node("ScrollContainer")):
			if c is Label:
				labels.append(c)
				c.connect("focus_exited",Callable(self,"_on_control_focus_exited"))
				c.connect("focus_entered",Callable(self,"_on_control_focus_entered"))
	
		# positions and sizes
		m.position = ANCHOR.position
		var sc = m.get_node("ScrollContainer")
		sc.size = Vector2(sc.size.x, 295)

		# theme the vertical scroll bar
		#sc.get_child(1).set_theme(vs_theme)

	# default menu
	$OPTIONS_menu.show()
	_current_menu = $OPTIONS_menu
	focus()

	#connect("toggle_SSAO",Callable(Game,"set_SSAO"))


func focus(index:int=0) -> void:
	_current_menu.get_node("ScrollContainer/VBoxContainer").get_child(index).grab_focus()


func _process(delta):
	pass


func _on_control_focus_exited():
	last_focus_owner = focus_owner
	var cc = last_focus_owner.get("custom_colors/font_color")
	last_focus_owner.set("custom_colors/font_color", Color(cc.r, cc.g, cc.b, label_opac_default ))


func _on_control_focus_entered():
	focus_owner = $OPTIONS_menu/ScrollContainer.get_viewport().gui_get_focus_owner()
	var cc = focus_owner.get("custom_colors/font_color")
	focus_owner.set("custom_colors/font_color", Color(cc.r, cc.g, cc.b, label_opac_focus ))


func _input(event):
	if event.is_action_pressed("ui_accept"):
		pprint("event: %s"%event)
	if event.is_action_pressed("ui_back"):
		# switch back to previous, or close
		prints("OPTIONS: BACK")
		if _current_menu.get_name().begins_with("OPTIONS"):
			emit_signal("close_options_menu")
		else:
			switch_menu(_previous_menu)


func switch_menu( menu_root:Node2D ) -> void:
	_previous_menu = _current_menu
	menu_root.show()
	_previous_menu.hide()
	_current_menu = menu_root
	focus()


#-- MENU panes -----------------------------------------------------------------

#-- OPTIONS --------------------------------------------------------------------
func _on_options_graphics_button_up():
	prints("OPTIONS menu -> GRAPHICS menu")
	switch_menu($GRAPHICS_menu)


func _on_options_debug_button_up():
	prints("OPTIONS menu -> DEBUG menu")
	switch_menu($DEBUG_menu)


func _on_options_quit_button_up():
	print("OPTIONS menu -> QUIT game")
	get_tree().quit()


#-- GRAPHICS -------------------------------------------------------------------
func _on_graphics_SSAO_toggled(button_pressed):
	# presently connected to game.sd autoload
	# TODO: change this (make a central configuration autoload)
	emit_signal("toggle_SSAO", button_pressed)


func pprint(thing) -> void:
	print("[options_menu_2d] %s"%str(thing))
