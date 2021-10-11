extends Spatial

export var inventory_ring_npoints = 32.0
export var inventory_ring_radius = 2.25

var ring_points= []

var _invoke_amount = 0.0

var is_invoked = false

var _gtime = 0.0


func _ready():
	self.visible = false
	_update_ring_points()

	$inventory_ring.points = ring_points
	$static_stack.set_as_toplevel(true) # to make control not concat parent's transforms 


func _update_ring_points() -> void:
	ring_points = []
	for i in range(inventory_ring_npoints):
		var p = (i/inventory_ring_npoints) * (2*PI)
		ring_points.append( Vector3( sin( p ) , 0.0, cos( p ) ) * inventory_ring_radius )
	ring_points.append( Vector3( sin( 2*PI ) , 0.0, cos( 2*PI ) ) * inventory_ring_radius ) 


func get_invoke_amount():
	# TODO : do this another way
	return _invoke_amount


func _process(dt):
	_gtime += dt

	if self.visible:
		# realign static_statck
		$static_stack.transform.origin = self.global_transform.origin + Vector3(0.0, 1.25, 0.0)
		$static_stack.set_rotation(Vector3(0.0, 0.0, 0.0))

		########################################################################
		# TODO : do this another way
		var g_dir = self.global_transform.basis.z
		# iter over static_stat/items
		for i in $static_stack/items.get_children():
			# pretend they're a type and "hightlight item"
			if g_dir.normalized().dot( i.global_transform.basis.z ) > (1.0 - 0.02):
				i.get_node("MeshInstance/outline").set_visible(true)
			else:
				i.get_node("MeshInstance/outline").set_visible(false)
		########################################################################


func invoke():
	is_invoked = true
	$invoke_tween.reset_all()
	$invoke_tween.remove_all()
	$invoke_tween.interpolate_property( $static_stack, "scale",
		Vector3(0.0002, 2.500, 0.0002), Vector3(1.0, 1.0, 1.0), 0.75,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$invoke_tween.interpolate_property( $inventory_ring, "scale",
		Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( $inventory_ring, "startThickness",
#		2.500, 0.075, 0.55,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( $inventory_ring, "endThickness",
#		2.50, 0.075, 0.55,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$invoke_tween.interpolate_property( self, "_invoke_amount",
		0.0, 1.0, 1.0,
		Tween.TRANS_LINEAR)
		
	$invoke_tween.start()
	self.visible = true


func devoke():
	is_invoked = false
	$invoke_tween.reset_all()
	$invoke_tween.remove_all()
	$invoke_tween.interpolate_property( $static_stack, "scale",
		Vector3(1.0, 1.0, 1.0), Vector3(0.0002, 2.50, .0002), 0.4,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	$invoke_tween.interpolate_property( $inventory_ring, "scale",
		Vector3(1.0, 1.0, 1.0), Vector3(0.002, .002, .002), 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
#	$invoke_tween.interpolate_property( $inventory_ring, "startThickness",
#		.075, 0.25, 0.3,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( $inventory_ring, "endThickness",
#		.075, 0.25, 0.3,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$invoke_tween.interpolate_property( self, "_invoke_amount",
		1.0, 0.0, 1.0,
		Tween.TRANS_LINEAR)
	$invoke_tween.start()


func _on_invoke_tween_tween_completed(object, key):
	#if self.scale.x == 0.002 :
	if self._invoke_amount == 0.0:
		self.visible = false
