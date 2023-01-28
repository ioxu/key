extends Node

@export var main_subviewport : SubViewport

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
	debug_draw_options = self.find_child("debug_draw_options")
	debug_draw_options.clear()
	for i in DEBUG_DRAW_ENUM_STRINGS:
		debug_draw_options.add_item(i)


func _process(delta):
	pass


func _on_debug_draw_options_item_selected(index):
	main_subviewport.set_debug_draw( index )


func pprint(thing) -> void:
	print("[ui_debug_mnenu] %s"%str(thing))


	
