extends PanelContainer

@onready var total_objects_in_frame: Label
@onready var total_primitives_in_frame: Label
@onready var total_draw_calls_in_frame: Label
@onready var texture_mem_used: Label
@onready var buffer_mem_used: Label
@onready var video_mem_used: Label

# units
# 0.000001 : btyes to MegaBytes (MB)
# 1/1048576 : btyes to Mebibytes (MiB)
var MiB_f = 1.0/1048576

func _ready():
	total_objects_in_frame = self.find_child("total_objects_in_frame")
	total_primitives_in_frame = self.find_child("total_primitives_in_frame")
	total_draw_calls_in_frame = self.find_child("total_draw_calls_in_frame")
	texture_mem_used = self.find_child("texture_mem_used")
	buffer_mem_used = self.find_child("buffer_mem_used")
	video_mem_used = self.find_child("video_mem_used")


func _process(_delta):
	pass


func _on_timer_timeout():
	total_objects_in_frame.text = "objects %s"%RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)
	total_primitives_in_frame.text = "primitives %s"%RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	total_draw_calls_in_frame.text = "draw calls %s"%RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	texture_mem_used.text = "texture mem %0.1f MiB"%( MiB_f * RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED))
	buffer_mem_used.text = "buffer mem %0.1f MiB"%( MiB_f * RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_BUFFER_MEM_USED))
	video_mem_used.text = "video mem %0.1f MiB"%(MiB_f * RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED))
