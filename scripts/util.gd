extends Node
# contains utility functions
# - math shaping functions

func _ready():
	print("util.dg autoload ready")


# maths 

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

