extends Spatial

var slotted_weapon = null

func _ready():
	$bg/outline.visible = false
	$bg/selected.visible = false


func set_weapon(weapon):
	#weapon.get_parent().remove_child( weapon )
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
