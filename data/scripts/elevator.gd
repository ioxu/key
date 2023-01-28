extends MeshInstance3D

var start_position: Vector3
var end_position: Vector3

@export var speed := 8.0

var gtime = 0.0

func _ready():
	start_position = self.global_transform.origin
	end_position = self.global_transform.origin + Vector3(0.0, 17.5, 0.0)


func _process(dt):
	gtime += dt
	
	# https://www.desmos.com/calculator/htrc6chioh
	var mt = ((fmod( gtime, speed ) / speed) -0.5 ) * 2.0
	var contrast = 2.2
	mt = ((abs(mt)-0.5) * contrast ) + 0.5
	mt = clamp(mt, 0.0, 1.0)
	
	self.transform.origin = lerp( start_position, end_position, mt )
	
