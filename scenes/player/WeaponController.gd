extends Node

export(NodePath) var PlayerPath  = ""
onready var player : KinematicBody = get_node(PlayerPath)
export(NodePath) var DUI_Root = ""
onready var dui_root : Spatial = get_node(DUI_Root)
export(NodePath) var EquipSlots = ""
onready var equip_slots : Spatial = get_node(EquipSlots)

onready var weapon = null #player.find_node("weapon_mount").get_child(0)

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
			switch_weapon()
			weapon_switch_selected = true

	if not dui_root.is_options_invoked:

		# toggle active weapon
		# double tap within time WEAPON_SWITCH_DOUBLTAP_TME
		# no more tap until WEAPON_SWITCH_MAX_TME
		if Input.is_action_just_pressed("switch_weapons"):
			if not weapon_switch_engaged:
				weapon_switch_time = 0.0
				weapon_switch_engaged = true
			elif weapon_switch_time < WEAPON_SWITCH_DOUBLTAP_TME:
				prints("dbl TAP", weapon_switch_time)
				weapon_switch_selected = true
				switch_weapon( true )
			elif weapon_switch_time > WEAPON_SWITCH_DOUBLTAP_TME:
				prints("miss TAP", weapon_switch_time)
				weapon_switch_selected = true
				switch_weapon()


		# shoot
		if self.weapon and Input.is_action_just_pressed("shoot"):
			weapon.activated = true

		if self.weapon and Input.is_action_just_released("shoot"):
			weapon.activated = false

		# TEMP: FIRE ALL IN INVENTORY ##############################################################
		if Input.is_action_just_pressed("shoot"):
			for w in dui_root.find_node("slots").get_children():
				w.slotted_weapon.eject_casings = false
				
				yield(get_tree().create_timer( randf() * 0.002 ), "timeout")
				w.slotted_weapon.activated = true

		if Input.is_action_just_released("shoot"):
			for w in dui_root.find_node("slots").get_children():
				w.slotted_weapon.activated = false
		#\TEMP: FIRE ALL IN INVENTORY ##############################################################


func switch_weapon( double_tap: bool = false) -> void:
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
	
