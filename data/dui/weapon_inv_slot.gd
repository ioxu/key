extends Spatial

export(float) var opacity := 1.0 setget set_opactiy, get_opacity

var _do_hide := false setget set_do_hide

var slotted_weapon = null

var _gtime = 0.0

var starting_col : Color

func _ready():
	$bg/outline.visible = false
	$bg/selected.visible = false

	starting_col = $bg.get_surface_material(0).get_albedo()
	set_opactiy(0.0)


func _process(delta):
	_gtime += delta

	if not _do_hide and self.is_visible() == false:
		self.set_visible(true)

	if is_equal_approx( opacity, 0.0 ) and _do_hide:
		for c in self.get_child(0).get_children():
			if not c.get_name() in ["outline", "selected"]:
				if c.is_visible():
					c.hide()
		return
	
	elif is_equal_approx( opacity, 1.0 ) and not _do_hide:
		for c in self.get_child(0).get_children():
			if not c.get_name() in ["outline", "selected"]:
				if not c.is_visible():
					c.show()
		return

	if _do_hide and opacity > 0.0:
		self.opacity = lerp(opacity, 0.0, 0.2)
	elif not _do_hide and opacity < 1.0:
		self.opacity = lerp(opacity, 1.0, 0.2 )


func set_do_hide(new_value : bool) -> void:
	_do_hide = new_value


func set_weapon(weapon):
	$bg.add_child( weapon )
	weapon.set_owner( $bg )
	weapon.transform.origin = Vector3.ZERO
	self.slotted_weapon = weapon


func remove_weapon():
	$bg.remove_child(self.slotted_weapon)
	self.slotted_weapon = null


func hilight( show: bool = false) -> void :
	$bg/outline.visible = show
	
	
func select( show: bool = false ) -> void:
	$bg/selected.visible = show


func has_weapon() -> bool:
	if self.slotted_weapon:
		return true
	else:
		return false


func set_opactiy(new_value) -> void:
	opacity = new_value
	var newc = Color( starting_col.r, starting_col.g, starting_col.b, starting_col.a * new_value )
	$bg.get_surface_material(0).set_albedo( newc )


func get_opacity() -> float:
	return opacity
