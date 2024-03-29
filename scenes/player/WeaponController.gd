extends Node

@export var PlayerPath: NodePath
@onready var player : CharacterBody3D = get_node(PlayerPath)
@export var WeaponMountPath: NodePath
@onready var weapon_mount : Node3D = get_node(WeaponMountPath)
@export var DUI_Root: NodePath
@onready var dui_root : Node3D = get_node(DUI_Root)
@export var EquipSlots: NodePath
@onready var equip_slots : Node3D = get_node(EquipSlots)

@onready var weapon = null #player.find_child("weapon_mount").get_child(0)
@onready var weapon_equip_slot = null # the weapon_equip_slot this weapon came from

# activate processing or not
@export var active := true


# weapon switching and equipping
var weapon_current_equip_slot : int = 0
var weapon_switch_engaged := false 
var weapon_switch_time := 0.0
var weapon_switch_selected
const WEAPON_SWITCH_DOUBLTAP_TME := 0.25
const WEAPON_SWITCH_MAX_TME := 0.45


var weapon_equips_from_equip_slots = {}

func _ready():
	if player.find_child("weapon_mount").get_child_count() > 0:
		weapon = player.find_child("weapon_mount").get_child(0)
	equip_slots.get_child(0).show_equip_indicator(true)
	
	# connect signals in equip_slots
	for c in equip_slots.get_children():
		c.connect("weapon_equip_slot_set",Callable(self,"_on_weapon_equip_slot_set"))


func _process(dt):
	weapon_switch_time +=dt

	if self.active:

		# toggle active weapon
		# times out and resets timers
		if weapon_switch_engaged:
			if weapon_switch_time > WEAPON_SWITCH_MAX_TME:
				weapon_switch_engaged = false
				weapon_switch_selected =  false
			# if ovr double tap timer, register the single click
			elif weapon_switch_time > WEAPON_SWITCH_DOUBLTAP_TME and not weapon_switch_selected:
				prints("single TAP >", weapon_switch_time)
				toggle_weapon()
				weapon_switch_selected = true

		if not dui_root.is_options_invoked:

			# toggle active weapon
			# double tap within time WEAPON_SWITCH_DOUBLTAP_TME
			# no more tap until WEAPON_SWITCH_MAX_TME
			if Input.is_action_just_pressed("toggle_weapons"):
				if weapon:
					weapon.activated = false
				if not weapon_switch_engaged:
					weapon_switch_time = 0.0
					weapon_switch_engaged = true
				elif weapon_switch_time < WEAPON_SWITCH_DOUBLTAP_TME:
					prints("dbl TAP", weapon_switch_time)
					weapon_switch_selected = true
					toggle_weapon( true )
				elif weapon_switch_time > WEAPON_SWITCH_DOUBLTAP_TME:
					prints("miss TAP", weapon_switch_time)
					weapon_switch_selected = true
					toggle_weapon()

			# shoot
			if self.weapon and Input.is_action_just_pressed("shoot"):
				#weapon.activated = true
				weapon.set_activated(true)

			if self.weapon and Input.is_action_just_released("shoot"):
				#weapon.activated = false
				weapon.set_activated(false)

			# TEMP: FIRE ALL IN INVENTORY ##############################################################
	#		if Input.is_action_just_pressed("shoot"):
	#			for w in dui_root.find_child("slots").get_children():
	#				w.slotted_weapon.eject_casings = false
	#
	#				await get_tree().create_timer( randf() * 0.002 ).timeout
	#				w.slotted_weapon.activated = true
	#
	#		if Input.is_action_just_released("shoot"):
	#			for w in dui_root.find_child("slots").get_children():
	#				w.slotted_weapon.activated = false
			#\TEMP: FIRE ALL IN INVENTORY ##############################################################


func slot_weapon(weapon : Weapon = null, slot : int = 0) -> void:
	"""
	quickly puts a weapon into a slot (index)
	and enables it.
	Avoids having to put a weapon in inventory and then use the interactiveinventory switcher to enable a weapon
	"""
	pprint("slot_weapon %s"%weapon)
	get_equipped_slot().set_weapon( weapon,  )


func toggle_weapon( double_tap: bool = false) -> void:
	get_equipped_slot().reset_weapon_transform()
	if double_tap == true:
		if weapon_current_equip_slot == 0 or weapon_current_equip_slot == 1:
			weapon_current_equip_slot = 2
		elif weapon_current_equip_slot == 2:
			weapon_current_equip_slot = 0
	else:
		if weapon_current_equip_slot == 0:
			weapon_current_equip_slot = 1
		elif weapon_current_equip_slot == 1:
			weapon_current_equip_slot = 0
		elif weapon_current_equip_slot == 2: # if in 3rd weapon, don't need to double-press out of it
			weapon_current_equip_slot = 0

	var eslots = equip_slots.get_children()
	for i in range(eslots.size()):
		if weapon_current_equip_slot == i:
			eslots[i].show_equip_indicator(true)
		else:
			eslots[i].show_equip_indicator(false)
	update_equipped_weapon()


func _on_weapon_equip_slot_set(slot) -> void:
	# i think only gets called when a weapon in dropped
	# onto a (the) actively equippped equip slot
	prints("_on_weapon_equip_slot_set", slot.get_path())
	update_equipped_weapon()


func get_equipped_slot():
	var eq = null
	for c in equip_slots.get_children():
		if c.is_current_equip_slot():
			eq = c
			return c
		else:
			pass
	if eq == null:
		prints("NO SLOTS ARE CURRENT")


func update_equipped_weapon() -> void:
	# is called when switching the current equip
	# do the actual move to weapon mount
	# and hook signals
	# and de-move equipped weapon
	# and unhook signals
	prints("updating equipped weapon")
	prints("  current slot n", weapon_current_equip_slot )
	prints("  current slot", get_equipped_slot().get_path() )
	if self.weapon ==  null:
		if get_equipped_slot().has_slotted_weapon():
			# no weapon equipped yet, set from selected equip
			set_weapon_from_equipped_slot()
		else:
			# no weapon equipped yet, nothing to slot from
			clear_weapon()
	else:
		if get_equipped_slot().has_slotted_weapon():
			if get_equipped_slot().slotted_weapon == self.weapon:
				# selected weapon already equipped
				pass
			else:
				# switch weapon to equipped
				set_weapon_from_equipped_slot()
		else:
			# switched-to slot is empty, don't change weapon
			pass

	pprint("update_equipped_weapon() self.weapon %s done."%self.weapon)


func set_weapon_from_equipped_slot() -> void:
	# move this function to player???
	
	self.weapon = get_equipped_slot().slotted_weapon
	
	# store which weapon came from which equip slot
	weapon_equips_from_equip_slots[weapon] = get_equipped_slot()
	print("\nhistory of weapons from equip_slots")
	for key in weapon_equips_from_equip_slots.keys():
		prints("  ", key, ":", weapon_equips_from_equip_slots[key])
	print("")

	# return currently mounted weapon to equip slot
	if weapon_mount.get_child_count() > 0:
		var mounted_weapon = weapon_mount.get_child(0)
		pprint( "[set_weapon_from_equipped_slot] mounted_weapon: %s"%mounted_weapon )
		if mounted_weapon:
			var original_equip_slot = weapon_equips_from_equip_slots[mounted_weapon]
			pprint(" return %s to %s"%[mounted_weapon, original_equip_slot])
			original_equip_slot.return_weapon()
			mounted_weapon = null

	# move weapon to actual mount
	get_equipped_slot().get_child(0).remove_child( weapon )
	weapon_mount.add_child( weapon )
	self.weapon.global_transform = weapon_mount.global_transform
	weapon.set_owner( weapon_mount )

	# do weapon connections
	pprint("[set_weapon_from_equipped_slot] .. connenct signals")
	if self.weapon.is_connected("fired",Callable(player,"_on_weapon_fire")):
		self.weapon.disconnect("fired",Callable(player,"_on_weapon_fire"))
	player.set_current_weapon( self.weapon )
	var _res = weapon.connect("fired",Callable(player,"_on_weapon_fire"))
	pprint("[set_weapon_from_equipped_slot] .. signals connect result: %s"%_res)


func clear_weapon() -> void:
	self.weapon = null


func pprint(thing) -> void:
	print("[WeaponController] %s"%str(thing))
