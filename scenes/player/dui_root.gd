extends Spatial

export var inventory_ring_npoints = 32.0
export var inventory_ring_radius = 2.25

var ring_points= []

var _gtime = 0.0

func _ready():
	_update_ring_points()
	$inventory_ring.points = ring_points


func _update_ring_points() -> void:
	ring_points = []
	for i in range(inventory_ring_npoints):
		var p = (i/inventory_ring_npoints) * (2*PI)
		ring_points.append( Vector3( sin( p ) , 0.0, cos( p ) ) * inventory_ring_radius )
	ring_points.append( Vector3( sin( 2*PI ) , 0.0, cos( 2*PI ) ) * inventory_ring_radius ) 


func _process(dt):
	_gtime += dt
#	var _s = ((sin(_gtime * 10.0) + 1.0) * 0.5) * 0.05 + 0.95
#	$inventory_ring.scale = Vector3( _s, 1.0, _s )


func invoke():
	$invoke_tween.interpolate_property( self, "scale",
		#Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
		Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$invoke_tween.start()
	self.visible = true


func devoke():
	$invoke_tween.interpolate_property( self, "scale",
		#Vector3(1.0, 1.0, 1.0), Vector3(0.002, 0.002, 0.002), 0.3,
		Vector3(1.0, 1.0, 1.0), Vector3(0.002, .002, .002), 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	$invoke_tween.start()


func _on_invoke_tween_tween_completed(object, key):
	if self.scale.x == 0.002 :
		self.visible = false
