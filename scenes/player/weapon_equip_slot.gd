extends Spatial

var slotted_weapon = null
var slotted_weapon_inv_slot = null
var starting_col : Color


func _ready():
	starting_col = $bg.get_material_override().get_albedo()
	hilight(false)


func set_weapon(weapon, inv_slot) -> void:
	if self.slotted_weapon:
		slotted_weapon_inv_slot.return_weapon()
	weapon.get_parent().remove_child( weapon )
	$bg.add_child( weapon )
	weapon.set_owner( $bg )
	weapon.transform.origin = Vector3(0.0, 0.0, 3.5) # radius of the $bg cylinder
	self.slotted_weapon = weapon
	self.slotted_weapon_inv_slot = inv_slot


func hilight( show: bool = false) -> void :
	#$bg/outline.visible = show
	if show:
		$bg.get_material_override().albedo_color = Color(starting_col.r,
												starting_col.g,
												starting_col.b,1.0)
	else:
		$bg.get_material_override().albedo_color = starting_col
	pass

