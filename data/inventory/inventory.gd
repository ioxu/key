extends Resource
class_name Inventory

export var inventory_name := "inventory"
export var n_slots : int = -1
export var _weapon_items = Array() setget set_weapon_items, get_weapon_items

# currencies 
var n_orbs := 0 

# weapons
var n_weapons := 0

signal inventory_changed(inventory)
signal inventory_weapon_item_added(inventory, weapon, quantity)


func set_weapon_items(new_items: Array) -> void:
	_weapon_items = new_items
	emit_signal("inventory_changed" ,self)


func get_weapon_items() -> Array:
	return _weapon_items


func get_weapon_item(index:int):
	return _weapon_items[index]


func add_weapon_item(item, quantity):
	# TODO: add stackable slots logic (https://www.youtube.com/watch?v=hYRN0eYttLc&ab_channel=CodewithTom)
	if item is Weapon:
		_weapon_items.append( item )
		n_weapons = self._weapon_items.size()
		emit_signal("inventory_changed" ,self)
		emit_signal("inventory_weapon_item_added", self, item, quantity)


func add_orbs(norbs:int = 0) -> void:
	self.n_orbs += norbs
	emit_signal("inventory_changed" ,self)


