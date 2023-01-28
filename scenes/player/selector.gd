extends Node3D

# interacts with weapon inventory slots res://data/dui/weapon_inv_slot.tscn

var selected_item = null
var selected_item_slot = null
var has_item = false

func _ready():
	pass

func select( object, slot ):
	# slot is a res://data/dui/weapon_inv_slot.tscn
	selected_item = object
	selected_item_slot = slot
	has_item = true
	# reparent
	object.get_parent().remove_child( object )
	add_child( object )
	object.set_owner( self )
	object.transform.origin = Vector3.ZERO + Vector3(0.0, 0.0, 1.0)
 

func clear():
	# empty selector
	# return weapon to slot
	if selected_item:
		selected_item = null
		has_item = false
		#selected_item_slot.return_weapon()
		selected_item_slot = null
