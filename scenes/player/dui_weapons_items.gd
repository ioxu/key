extends Spatial
# script for the dui_root weapons_items parent

export var hilight_direction_tolerance := 0.02				# closeness to 1.0 (direction dot weapon_inv_slot.basis.z)
export var item_spacing := 25.0 setget set_item_spacing		# degrees around y that items are spaced 

export(int) var visible_list_max_items_visible := 6
export(float) var visible_list_offset := 0

var visible_list_minimum_offset := 0

var weapon_item_hilighted = null
var weapon_item_selected = null

# res
var weapon_inv_slot = preload("res://data/dui/weapon_inv_slot.tscn")


func _ready():
	# remove default weapon slot
	$slots/weapon_inv_slot.queue_free()

	$selector.visible = false

	visible_list_offset = (-1.0 * float(visible_list_max_items_visible) / 2.0) + 1.0
	visible_list_minimum_offset = visible_list_offset

func select() -> void:
	if !weapon_item_selected and weapon_item_hilighted:
		weapon_item_selected = weapon_item_hilighted
		weapon_item_selected.select(true)
		prints("weapon_items", "select", find_item( weapon_item_selected ) ,weapon_item_selected, weapon_item_selected.slotted_weapon)
		Util.debug_stack("")
		$selector.visible = true


func release_select() -> void:
	if weapon_item_selected:
		weapon_item_selected.select(false)
		weapon_item_selected = null
	$selector.visible = false


func update( delta : float,  basis : Basis = Basis.IDENTITY ) -> void:
	# update pointing direction
	# update hilighted item

	# find closest item to hilight
	var closest_item = null
	weapon_item_hilighted = null
	var closest_dir = 0.0
	for c in $slots.get_children():
		c.hilight(false)
		var d = basis.z.normalized().dot( c.global_transform.basis.z )
		var within_hilight_range =  d > (1.0 - hilight_direction_tolerance)
		if within_hilight_range:
			if d > closest_dir:
				closest_dir = d
				closest_item = c

	if closest_item:
		closest_item.hilight( true )
		weapon_item_hilighted = closest_item

	# ################################
	if weapon_item_selected:
		pass
	# ################################

	if $selector.visible:
		$selector.global_transform.basis = basis


func weapon_inventory_changed( inventory ) -> void:
	var n_weapon_slots = $slots.get_child_count()
	
	# add extra slots if needed
	if inventory.n_weapons > n_weapon_slots:
		var slots_to_add = inventory.n_weapons - n_weapon_slots
		for _i in range(slots_to_add):
			var wis = weapon_inv_slot.instance()
			wis.set_do_hide(false)
			$slots.add_child(wis)

		# fill out weapon_inv_slots with weapons, as listed in inventory weapon items
		var ws = $slots.get_children()
		for i in range(inventory.n_weapons):
			if not ws[i].has_weapon():
				ws[i].set_weapon( inventory.get_weapon_item(i) )

		_arrange_items( item_spacing )


func set_item_spacing( new_value ) -> void:
	_arrange_items(new_value)


func _arrange_items( spacing : float = item_spacing) -> void:
	# space out $static_stack/inventory_items/weapons_items children
	var ws = $slots.get_children()
	for i in range(ws.size()):
		var offset_index = i+visible_list_offset
		var suffix = ""
		if offset_index < -2 or offset_index > 3:
			suffix = "hide"
			ws[i].set_do_hide(true)
		else:
			suffix = "show"
			ws[i].set_do_hide(false)
		prints( "\tarrange (%s, >%s) %s"%[i, offset_index, suffix ] )
		ws[i].set_rotation_degrees(Vector3(0.0, (i + -0.5 + visible_list_offset) * spacing , 0.0))


func shift_left() -> void:
	# shit the list to the left 
	var ns = get_n_slots()
	if ns < visible_list_max_items_visible: return

	var right_limit = -visible_list_max_items_visible/2.0 +1.0
	if visible_list_offset >= right_limit:
		return

	visible_list_offset +=1
	prints("inventory_items shift_left <-- (%s, %s, n %s)"%[visible_list_offset, right_limit, ns])
	_arrange_items()


func shift_right() -> void:
	# shit the list to the right
	var ns = get_n_slots()
	if ns < visible_list_max_items_visible: return

	var left_limit = (visible_list_max_items_visible/2.0) - ns +1.0
	if visible_list_offset <=  left_limit:
		return
		
	visible_list_offset -=1
	prints("inventory_items shift_right --> (%s, %s, n %s)"%[visible_list_offset, left_limit, ns])
	_arrange_items()


func get_n_slots() -> int:
	return $slots.get_children().size()


func find_item( item ) -> int:
	# find item's index in slots
	var ws = $slots.get_children()
	return ws.find(item)
