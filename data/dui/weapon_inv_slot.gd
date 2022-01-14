extends Spatial

export(float) var opacity := 1.0 setget set_opactiy, get_opacity

var slotted_weapon = null

var _gtime = 0.0

var starting_col : Color

func _ready():
	$bg/outline.visible = false
	$bg/selected.visible = false

	starting_col = $bg.get_surface_material(0).get_albedo()


func _process(delta):
	_gtime += delta
	var opac = (sin(_gtime * 30.0) + 1.0) / 2.0
	self.set_opactiy( opac )


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
	var newc = Color( starting_col.r, starting_col.g, starting_col.b, starting_col.a * opacity )
	$bg.get_surface_material(0).set_albedo( newc )


func get_opacity() -> float:
	return opacity
