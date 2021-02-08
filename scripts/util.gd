extends Node
# contains utility functions
# - math shaping functions

func _ready():
	print("game.dg autoload ready")


# maths 

# bias
func bias(value, b):
	b = -log2(1.0 - b)
	return 1.0 - pow(1.0 - pow(value, 1.0/b), b)


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


# range
func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
