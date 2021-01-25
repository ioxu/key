extends Node
# contains utility functions
# - math shaping functions

func _ready():
	print("game.dg autoload ready")


# math 

func bias(value, b):
	b = -log2(1.0 - b)
	return 1.0 - pow(1.0 - pow(value, 1.0/b), b)


func log2(value):
	return log(value) / log(2)


func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
