extends Spatial
# script for the dui_root weapons_items parent

export var hilight_direction_tolerance := 0.02			   # closeness to 1.0 (direction dot weapon_inv_slot.basis.z)
export var item_spacing := 25.0 setget set_item_spacing	   # degrees around y that items are spaced 

var weapon_item_hilighted = null
var weapon_item_selected = null

# res
var weapon_inv_slot = preload("res://data/dui/weapon_inv_slot.tscn")


func _ready():
	# remove default weapon slot
	$weapon_inv_slot.queue_free()


func update( direction : Vector3 = Vector3.FORWARD ) -> void:
	# update pointing direction
	# update hilighted item

	# find closest item to hilight
	var closest_item = null
	var closest_dir = 0.0
	for c in get_children():
		c.hilight(false)
		var d = direction.normalized().dot( c.global_transform.basis.z )
		var within_hilight_range =  d > (1.0 - hilight_direction_tolerance)
		if within_hilight_range:
			if d > closest_dir:
				closest_dir = d
				closest_item = c
			
	if closest_item:
		closest_item.hilight( true )


func weapon_inventory_changed( inventory ) -> void:
	var n_weapon_slots = get_child_count()
	
	# add extra slots if needed
	if inventory.n_weapons > n_weapon_slots:
		var slots_to_add = inventory.n_weapons - n_weapon_slots
		for _i in range(slots_to_add):
			var wis = weapon_inv_slot.instance()
			add_child(wis)

		# fill out weapon_inv_slots with weapons, as listed in inventory weapon items
		var ws = get_children()
		for i in range(inventory.n_weapons):
			if not ws[i].has_weapon():
				ws[i].set_weapon( inventory.get_weapon_item(i) )

		_arrange_items( item_spacing )


func set_item_spacing( new_value ) -> void:
	_arrange_items(new_value)


func _arrange_items( spacing : float = 25.0) -> void:
	# space out $static_stack/inventory_items/weapons_items children
	var ws = get_children()
	if ws.size() > 1:
		for i in range(ws.size()):
			var yr = lerp( -(ws.size()-1.0)/2.0, (ws.size()-1.0)/2.0, i/float((ws.size()-1)) )
			ws[i].set_rotation_degrees(Vector3(0.0, yr * spacing, 0.0))

