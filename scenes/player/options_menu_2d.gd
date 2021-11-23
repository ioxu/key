extends Node2D

var global_time = 0

var f6 = false #true if run in F6 mode (see Util.is_f6())

var label_opac_default = .4
var label_opac_focus = 1.0
var focus_owner = null
var last_focus_owner = null

# override ScrollContainer vertical scroll bar theme 
var vs_theme = preload("res://scenes/player/options_menu_vscrollbar_theme.tres")


func _ready():
	prints("options_menu_2d ready")
	print("  ScrollContiner children")
	var labels = []
	for c in Util.get_all_children($ScrollContainer):
		if c is Label:
			labels.append(c)
			c.connect( "focus_exited", self, "_on_control_focus_exited" )
			c.connect( "focus_entered", self, "_on_control_focus_entered" )
	prints("  LABELS", labels)

	# set scrollcontainer size and vscrollbar theme
	$ScrollContainer.rect_size = Vector2($ScrollContainer.rect_size.x, 296)
	var _v_scroll = $ScrollContainer.get_child(1)
	_v_scroll.set_theme(vs_theme)

	$ScrollContainer/VBoxContainer/game.grab_focus()


func focus():
	# should call this once invoking the options_menu_2d
	$ScrollContainer/VBoxContainer/game.grab_focus()


func _process(delta):
	pass


func _on_control_focus_exited():
	last_focus_owner = focus_owner
	var cc = last_focus_owner.get("custom_colors/font_color")
	last_focus_owner.set("custom_colors/font_color", Color(cc.r, cc.g, cc.b, label_opac_default ))


func _on_control_focus_entered():
	focus_owner = $ScrollContainer.get_focus_owner()
	var cc = focus_owner.get("custom_colors/font_color")
	focus_owner.set("custom_colors/font_color", Color(cc.r, cc.g, cc.b, int(255*label_opac_focus) ))


func _input(event):
		if event.is_action_pressed("ui_accept"):
			if $ScrollContainer.get_focus_owner().name == "exit":
				print("EXIT game from options menu")
				get_tree().quit()
 
		if event.is_action_pressed("ui_back"):
			pass



