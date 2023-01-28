extends Node

var gtime := 0.0

@export var main_subviewport : SubViewport

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


func _ready():
	# set self INVISIBLE
	self.get_child(0).set_visible(false)
	
	debug_draw_options = self.find_child("debug_draw_options")
	debug_draw_options.clear()
	for i in DEBUG_DRAW_ENUM_STRINGS:
		debug_draw_options.add_item(i)


func _process(delta):
	gtime += delta
	var lod_f = (sin(gtime* 1.0) + 1.0) / 2.0
	lod_f *= 80.0
	pprint("lod_f %s"%lod_f)
	main_subviewport.mesh_lod_threshold = lod_f


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		self.get_child(0).set_visible(true)
		self.is_active = true
	elif event.is_action_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.get_child(0).set_visible(false)
		self.is_active = false


func _on_debug_draw_options_item_selected(index):
	main_subviewport.set_debug_draw( index )


func pprint(thing) -> void:
	print("[ui_debug_mnenu] %s"%str(thing))


func _on_quit_button_pressed():
	get_tree().quit()
