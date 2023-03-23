extends Node

var gtime := 0.0

@export var main_subviewport : SubViewport

@export var ui_debug_root : Node

var is_active := false

var debug_draw_options : OptionButton
const DEBUG_DRAW_ENUM_STRINGS = [
	"Disabled",
	"Unshaded",
	"Lighting",
	"Overdraw",
	"Wireframe",
	"Normal Buffer",
	"Voxel GI Albedo",
	"Voxel GI Lighting",
	"Voxel GI Emission",
	"Shadow Atlas",
	"Directional Shadow Atlas",
	"Scene Illuminance",
	"Screenspace Ambient Occlusion",
	"Screenspace Indirect Illumination",
	"PSSM Splits",
	"Decal Atlas",
	"SDFGI Cascades",
	"SDFGI Probes",
	"GI Buffer",
	"Disable LOD",
	"Cliuster Omni Lights",
	"Cluster Spot Lights",
	"Cluster Decals",
	"Cluster Reflection Probes",
	"Occluders",
	"Motion Vectors",
]

var _previous_focus_holder : Control


func _ready():
	# set self INVISIBLE
	self.get_child(0).set_visible(false)
	
	debug_draw_options = self.find_child("debug_draw_options")
	debug_draw_options.clear()
	for i in DEBUG_DRAW_ENUM_STRINGS:
		debug_draw_options.add_item(i)

	# set defaults:
	self.find_child("resolutions_overlay_checkbox").set_pressed(false)
	self.find_child("renderingServer_info_overlay_checkbox").set_pressed(false)


func _process(_delta):
#	gtime += delta
#	var lod_f = (sin(gtime* 1.0) + 1.0) / 2.0
#	lod_f *= 80.0
#	main_subviewport.mesh_lod_threshold = lod_f
	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not self.is_active:
		pprint("invoke_this_menu() : _unhandled_input %s"%event)
		invoke_this_menu()
	elif event.is_action_pressed("ui_cancel") and self.is_active:
		pprint("devoke_this_menu() : _unhandled_input %s"%event)
		devoke_this_menu()
		
#	if event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
#		pprint("invoke_this_menu() : _unhandled_input %s"%event)
#		invoke_this_menu()
#	elif event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		pprint("devoke_this_menu() : _unhandled_input %s"%event)
#		devoke_this_menu()


func _on_debug_draw_options_item_selected(index):
	main_subviewport.set_debug_draw( index )


func pprint(thing) -> void:
	#print("[ui_debug_menu] %s"%str(thing))
	print_rich("[code][b][color=Slategray][ui_debug_menu][/color][/b][/code] %s" %str(thing))


func _on_return_button_pressed():
	devoke_this_menu()


func devoke_this_menu()->void:
	self.get_child(0).set_visible(false)
	self.is_active = false
	if _previous_focus_holder != null:
		_previous_focus_holder.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func invoke_this_menu()->void:
	self.get_child(0).set_visible(true)
	self.is_active = true
	_previous_focus_holder = get_viewport().gui_get_focus_owner()
	pprint("previous focus holder: %s"%_previous_focus_holder)
	self.find_child("return_button").grab_focus()


func _on_quit_button_pressed():
	Game.quit()


func _on_fps_overlay_checkbox_toggled(button_pressed):
	ui_debug_root.find_child("fps_display_container").set_visible( button_pressed )


func _on_resolutions_overlay_checkbox_toggled(button_pressed):
	ui_debug_root.find_child("resolutions_display_container").set_visible( button_pressed )


func _on_rendering_server_info_overlay_checkbox_toggled(button_pressed):
	ui_debug_root.find_child("renderingServer_info_display_container").set_visible( button_pressed )

# time control
func _on_play_timecontrol_texture_button_pressed():
	pprint("play_timecontrol pressed")


func _on_pause_timecontrol_texture_button_pressed():
	pprint("pause_timecontrol pressed")
