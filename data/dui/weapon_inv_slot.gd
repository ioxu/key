extends Spatial

export(float) var opacity := 1.0 setget set_opactiy, get_opacity

var is_invoked := false
var _invoke_amount := 0.0

var slotted_weapon = null

var _gtime = 0.0

var starting_col : Color

func _ready():
	$bg/outline.visible = false
	$bg/selected.visible = false

	starting_col = $bg.get_surface_material(0).get_albedo()
	is_invoked = false


func _process(delta):
	_gtime += delta


func invoke() -> void:
	if is_invoked:
		return
		
	self.visible = true
	$visibility_tween.reset_all()
	$visibility_tween.remove_all()
	$visibility_tween.interpolate_property( $bg, "scale",
		Vector3(0.0002, 2.500, 0.0002), Vector3(1.0, 1.0, 1.0), 0.75,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$visibility_tween.interpolate_property( self, "_invoke_amount",
		0.0, 1.0, 1.0,
		Tween.TRANS_LINEAR)
	$visibility_tween.start()
	is_invoked = true


func devoke() -> void:
	if is_invoked == false:
		return
		
	$visibility_tween.reset_all()
	$visibility_tween.remove_all()
	$visibility_tween.interpolate_property( $bg, "scale",
		Vector3(1.0, 1.0, 1.0), Vector3(0.0002, 2.50, .0002), 0.4,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	$visibility_tween.interpolate_property( self, "_invoke_amount",
		1.0, 0.0, 1.0,
		Tween.TRANS_LINEAR)
	$visibility_tween.start()
	is_invoked = false


func _on_visibility_tween_tween_completed(object, key):
	if self._invoke_amount == 0.0:
		self.visible = false


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



