extends PanelContainer

@export var main_viewport : SubViewport
@export var viewport_display_rect : TextureRect

var _r = false

func _ready() -> void:
	pprint( "main viewport %s (%s)"%[main_viewport.get_path(), main_viewport.get_class() ])
	pprint( "viewport display rect %s"%viewport_display_rect.get_path() )
	self._r = true
	update()
	main_viewport.connect("size_changed", self._on_Viewport_size_changed)
	viewport_display_rect.connect("resized", self._on_ViewportDisplayTextureRect_resized)


func update() -> void:
	var rr = main_viewport.get_size()
	self.find_child("viewport_resolution").text = "render %s x %s"%[rr[0], rr[1]]
	var wr = get_viewport().get_visible_rect().size
	self.find_child("window_resolution").text = "display %s x %s"%[wr[0], wr[1]]


func pprint(thing) -> void:
	print( "[resolutions_display_panel] %s"%str(thing) )


func _on_Viewport_size_changed() -> void:
	if self._r:
		self.update()


func _on_ViewportDisplayTextureRect_resized() -> void:
	if self._r:
		self.update()
