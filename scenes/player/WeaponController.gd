extends Node

export(NodePath) var PlayerPath  = ""
onready var player : KinematicBody = get_node(PlayerPath)
export(NodePath) var WeaponMountPath = ""
onready var weapon_mount : Spatial = get_node(WeaponMountPath)
export(NodePath) var DUI_Root = ""
onready var dui_root : Spatial = get_node(DUI_Root)
export(NodePath) var EquipSlots = ""
onready var equip_slots : Spatial = get_node(EquipSlots)

onready var weapon = null #player.find_node("weapon_mount").get_child(0)
onready var weapon_equip_slot = null # the weapon_equip_slot this weapon came from


# weapon switching and equipping
var weapon_current_equip_slot : int = 0
var weapon_switch_engaged := false 
var weapon_switch_time := 0.0
var weapon_switch_selected
const WEAPON_SWITCH_DOUBLTAP_TME := 0.25
const WEAPON_SWITCH_MAX_TME := 0.45


func _ready():
	if player.find_node("weapon_mount").get_child_count() > 0:
		weapon = player.find_node("weapon_mount").get_child(0)
	equip_slots.get_child(0).show_equip_indicator(true)
	
	# connect signals in equip_slots
	for c in equip_slots.get_children():
		c.connect("weapon_equip_slot_set", self, "_on_weapon_equip_slot_set")


func _process(dt):
	weapon_switch_time +=dt

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

	# update weapon to mount global transform
	if self.weapon:
		self.weapon.global_transform = weapon_mount.global_transform

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
#			for w in dui_root.find_node("slots").get_children():
#				w.slotted_weapon.eject_casings = false
#
#				yield(get_tree().create_timer( randf() * 0.002 ), "timeout")
#				w.slotted_weapon.activated = true
#
#		if Input.is_action_just_released("shoot"):
#			for w in dui_root.find_node("slots").get_children():
#				w.slotted_weapon.activated = false
		#\TEMP: FIRE ALL IN INVENTORY ##############################################################


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

	prints("self.weapon", self.weapon,"\n")


func set_weapon_from_equipped_slot() -> void:
	# move this function to player???
	self.weapon = get_equipped_slot().slotted_weapon
	if self.weapon.is_connected( "fire" , player, "_on_weapon_fire" ):
		self.weapon.disconnect("fire" , player, "_on_weapon_fire" )
	player.set_current_weapon( self.weapon )
	var _res = weapon.connect("fire", player, "_on_weapon_fire")


func clear_weapon() -> void:
	self.weapon = null

