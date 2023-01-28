extends Node3D

@export var opacity: float = 1.0 : get = get_opacity, set = set_opactiy

var is_invoked := false
var _invoke_amount := 0.0

var slotted_weapon = null

var _gtime = 0.0

var starting_col : Color

func _ready():
	$panel/outline.visible = false
	$panel/selected.visible = false

	starting_col = $panel.get_active_material(0).get_albedo()#.get_surface_override_material(0).get_albedo()
	is_invoked = false


func _process(delta):
	_gtime += delta


func invoke() -> void:
	if is_invoked:
		return
		
	self.visible = true
#	$visibility_tween.reset_all()
#	$visibility_tween.remove_all()
#	$visibility_tween.interpolate_property( $panel, "scale",
#		Vector3(0.0002, 2.500, 0.0002), Vector3(1.0, 1.0, 1.0), 0.75,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$visibility_tween.interpolate_property( self, "_invoke_amount",
#		0.0, 1.0, 1.0,
#		Tween.TRANS_LINEAR)
#	$visibility_tween.start()
	self._invoke_amount = 1.0
	self.scale = Vector3(1.0, 1.0, 1.0)
	is_invoked = true


func devoke() -> void:
	if is_invoked == false:
		return
		
#	$visibility_tween.reset_all()
#	$visibility_tween.remove_all()
#	$visibility_tween.interpolate_property( $panel, "scale",
#		Vector3(1.0, 1.0, 1.0), Vector3(0.0002, 2.50, .0002), 0.4,
#		Tween.TRANS_CUBIC, Tween.EASE_IN)
#	$visibility_tween.interpolate_property( self, "_invoke_amount",
#		1.0, 0.0, 1.0,
#		Tween.TRANS_LINEAR)
#	$visibility_tween.start()
	self.scale =  Vector3(0.0002, 2.50, .0002)
	self._invoke_amount = 0.0
	is_invoked = false


func _on_visibility_tween_tween_completed(_object, _key):
	if self._invoke_amount == 0.0:
		self.visible = false


func set_weapon(weapon) -> void:
	# a slotted weapon is slotted for ever
	# until remove_weapon()
	if not self.slotted_weapon:
		$panel.add_child( weapon )
		weapon.set_owner( $panel )
		weapon.transform.origin = Vector3.ZERO
		self.slotted_weapon = weapon


func return_weapon() -> void:
	if self.slotted_weapon:
		self.slotted_weapon.get_parent().remove_child( self.slotted_weapon )
		$panel.add_child( self.slotted_weapon )
		self.slotted_weapon.set_owner( $panel )
		self.slotted_weapon.transform.origin = Vector3.ZERO


func remove_weapon() -> void:
	$panel.remove_child(self.slotted_weapon)
	self.slotted_weapon = null


func hilight( _show: bool = false) -> void :
	$panel/outline.visible = _show


func select( _show: bool = false ) -> void:
	$panel/selected.visible = _show


func has_weapon() -> bool:
	if self.slotted_weapon:
		return true
	else:
		return false


func set_opactiy(new_value) -> void:
	opacity = new_value
	var newc = Color( starting_col.r, starting_col.g, starting_col.b, starting_col.a * new_value )
	$panel.get_surface_override_material(0).set_albedo( newc )


func get_opacity() -> float:
	return opacity



