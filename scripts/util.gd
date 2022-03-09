extends Node
# contains utility functions
# - math shaping functions

func _ready():
	print("util.dg autoload ready")


# ------------------------------------------------------------------------------
# context 
# ------------------------------------------------------------------------------


func is_f6(node:Node):
	# checks if node is running through GUI by F6,
	# TODO: needs rigorous testing
	return node.get_parent().get_path() == "/root/"


# ------------------------------------------------------------------------------
# maths 
# ------------------------------------------------------------------------------


func remap( f, start1, stop1, start2, stop2):
	return start2 + (stop2 - start2) * ((f - start1) / (stop1 - start1))


# remap that clamps between start2 and stop2
func remap_clamp(f, start1, stop1, start2, stop2):
	return clamp( start2 + (stop2 - start2) * ((f - start1) / (stop1 - start1)), start2, stop2 )


# fast bias, C. Schlick, Graphics Gems IV
func bias(value, b):
	b = -log2(1.0 - b)
	return 1.0 - pow(1.0 - pow(value, 1.0/b), b)


# fast gain, C. Schlick, Graphics Gems IV
func gain(t, g):
	if(t < 0.5):
		return bias(t * 2.0, g)/2.0
	else:
		return bias( t * 2.0 - 1.0, 1.0 - g )/2.0 + 0.5



func log2(value):
	return log(value) / log(2)


func bias_lut( b = 0.5, resolution = 32 ) -> Curve:
	# baked lut of biased values for a given bias, b.
	var lut = Curve.new()
	lut.bake_resolution = resolution
	resolution = float(resolution)
	for i in range(resolution):
		lut.add_point( Vector2(i/resolution, bias(i/resolution, b) ) )
	return lut


# ------------------------------------------------------------------------------
# arrays
# ------------------------------------------------------------------------------


func ring_points(npoints:int = 32, radius:float = 5.0) -> Array:
	# a ring of points on the x-z plane
	var ring_points = []
	for i in range(npoints):
		var p = (i/float(npoints)) * (2*PI)
		ring_points.append( Vector3( sin( p ) , 0.0, cos( p ) ) * radius )
	ring_points.append( Vector3( sin( 2*PI ) , 0.0, cos( 2*PI ) ) * radius )
	return ring_points


func arc_points(npoints:int = 10, start:float = 45.0, end:float = 315.0, radius:float = 5.0) -> Array:
	# an arc of points on the x-z plane
	# start and end are in degrees,
	# 0 degrees is at 3 o'clock on the x-z plane
	var arc_points = []
	for i in range(npoints+1):
		var p = deg2rad(start + i * (end-start) / float(npoints) - 90)
		arc_points.append( Vector3( cos( p ) , 0.0, sin( p ) ) * radius )
	return arc_points


# ------------------------------------------------------------------------------
# nodes
# ------------------------------------------------------------------------------


func set_tree_visible( node : Node, visible : bool) -> void:
	if node.has_method("set_visible"):
		node.set_visible( visible )
	for n in node.get_children():
		set_tree_visible( n, visible )


func get_all_children(node):
	# reursively get a list of all children
	var cl = []
	_gac_r(node, cl)
	return cl


func _gac_r(node, acc):
	# get_all_children recursoin
	for c in node.get_children():
		acc.append(c)
		if c.get_child_count() > 0 :
			_gac_r(c, acc)


# ------------------------------------------------------------------------------
# debug
# ------------------------------------------------------------------------------


func debug(text):
	# https://github.com/godotengine/godot/issues/18319#issuecomment-389895583
	var frame = get_stack()[1]
	print( "%30s:%-4d %s" % [frame.source.get_file(), frame.line, text] )


func debug_stack(text):
	# https://github.com/godotengine/godot/issues/18319#issuecomment-389895583
	print("debug_stack: %s"%[text])
	var st = get_stack()
	st.remove(0)
	for frame in st:
		print( "%30s:%-4d %s()" % [frame.source.get_file(), frame.line, frame.function] )
