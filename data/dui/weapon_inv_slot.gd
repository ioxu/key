extends Spatial

var slotted_weapon = null

func _ready():
	pass


func set_weapon(weapon):
	#weapon.get_parent().remove_child( weapon )
	$bg.add_child( weapon )
	weapon.set_owner( $bg )
	weapon.transform.origin = Vector3.ZERO
	self.slotted_weapon = weapon


func remove_weapon():
	$bg.remove_child(self.slotted_weapon)
	self.slotted_weapon = null


func has_weapon() -> bool:
	if self.slotted_weapon:
		return true
	else:
		return false
