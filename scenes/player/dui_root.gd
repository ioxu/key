extends Spatial

export var inventory_ring_npoints := 32.0
export var inventory_ring_radius := 2.25


var _invoke_amount = 0.0

var is_invoked = false

var _gtime = 0.0


func _ready():
	self.visible = false

	$inventory_ring.points =_generate_ring_points(inventory_ring_npoints, inventory_ring_radius)
	$weapons_ring.points = _generate_ring_points(inventory_ring_npoints, inventory_ring_radius * 0.95)
	$static_stack.set_as_toplevel(true) # to make control not concat parent's transforms 


func _generate_ring_points(npoints, radius) -> Array:
	var ring_points = []
	for i in range(npoints):
		var p = (i/npoints) * (2*PI)
		ring_points.append( Vector3( sin( p ) , 0.0, cos( p ) ) * radius )
	ring_points.append( Vector3( sin( 2*PI ) , 0.0, cos( 2*PI ) ) * radius )
	return ring_points


func get_invoke_amount():
	# TODO : do this another way
	return _invoke_amount


func _process(dt):
	_gtime += dt

	if self.visible:
		########################################################################
		# TODO : do this another way
		# realign static_statck
		$static_stack.transform.origin = self.global_transform.origin + Vector3(0.0, 1.25, 0.0)
		$static_stack.set_rotation(Vector3(0.0, 0.0, 0.0))

		var g_dir = self.global_transform.basis.z
		# iter over static_stat/items
		for i in $static_stack/inventory_items.get_children():
			# pretend they're a type and "hightlight item"
			if g_dir.normalized().dot( i.global_transform.basis.z ) > (1.0 - 0.02):
				i.get_node("MeshInstance/outline").set_visible(true)
			else:
				i.get_node("MeshInstance/outline").set_visible(false)
		########################################################################


func invoke_inventory_ring():
	if is_invoked:
		return
	is_invoked = true
	$weapons_ring.visible = false
	$inventory_ring.visible = true
	$static_stack/radar_dots.visible = false
	$static_stack/inventory_items.visible = true
	_invoke()


func invoke_weapons_ring():
	if is_invoked:
		return
	is_invoked = true
	$weapons_ring.visible = true
	$inventory_ring.visible = false
	$static_stack/radar_dots.visible = true
	$static_stack/inventory_items.visible = false
	_invoke()


func _invoke():
	#is_invoked = true
	$invoke_tween.reset_all()
	$invoke_tween.remove_all()
	$invoke_tween.interpolate_property( $static_stack, "scale",
		Vector3(0.0002, 2.500, 0.0002), Vector3(1.0, 1.0, 1.0), 0.75,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$invoke_tween.interpolate_property( $inventory_ring, "scale",
		Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$invoke_tween.interpolate_property( $weapons_ring, "scale",
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


func devoke_inventory_ring():
	if $weapons_ring.visible == true: 
		return
	else:
		_devoke()


func devoke_weapons_ring():
	if $inventory_ring.visible == true:
		return
	else:
		_devoke()


func _devoke():
	is_invoked = false
	$invoke_tween.reset_all()
	$invoke_tween.remove_all()
	$invoke_tween.interpolate_property( $static_stack, "scale",
		Vector3(1.0, 1.0, 1.0), Vector3(0.0002, 2.50, .0002), 0.4,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	$invoke_tween.interpolate_property( $inventory_ring, "scale",
		Vector3(1.0, 1.0, 1.0), Vector3(0.002, .002, .002), 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	$invoke_tween.interpolate_property( $weapons_ring, "scale",
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
