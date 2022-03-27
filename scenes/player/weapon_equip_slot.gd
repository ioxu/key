extends Spatial

var slotted_weapon = null
var slotted_weapon_inv_slot = null
var starting_col : Color
var _slot_position = Vector3(0.0, 0.0, 3.5) # radius of the $bg cylinder
signal weapon_equip_slot_set(equip_slot)


func _ready():
	starting_col = $bg.get_material_override().get_albedo()
	hilight(false)
	show_equip_indicator(false)


func set_weapon(weapon, inv_slot) -> void:
	# setting a weapon for the slot for the first time
	if self.slotted_weapon:
		slotted_weapon_inv_slot.return_weapon()
	weapon.get_parent().remove_child( weapon )
	$bg.add_child( weapon )
	weapon.set_owner( $bg )
	self.slotted_weapon = weapon
	self.reset_weapon_transform()
	if inv_slot != null:
		self.slotted_weapon_inv_slot = inv_slot
	if is_current_equip_slot():
		emit_signal("weapon_equip_slot_set", self)


func return_weapon() -> void:
	# when returning a child that has been set before
	self.slotted_weapon.get_parent().remove_child( self.slotted_weapon )
	$bg.add_child( self.slotted_weapon )
	self.slotted_weapon.set_owner( $bg )
	self.reset_weapon_transform()


func hilight( show: bool = false, mult: float = 1.0) -> void :
	#$bg/outline.visible = show
	if show:
		$bg.get_material_override().albedo_color = Color(starting_col.r,
												starting_col.g,
												starting_col.b,1.0) * mult
	else:
		$bg.get_material_override().albedo_color = starting_col


func is_current_equip_slot() -> bool:
	return $bg/equip_indicator.visible


func has_slotted_weapon() -> bool:
	if self.slotted_weapon:
		return true
	else:
		return false


func reset_weapon_transform() -> void:
	if slotted_weapon:
		slotted_weapon.transform.basis = Basis()
		slotted_weapon.transform.origin = _slot_position


func show_equip_indicator( show: bool = false ) -> void:
	$bg/equip_indicator.visible = show



