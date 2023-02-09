extends CharacterBody3D

@export var initial_health : float = 1000.0
var health : float : set = set_health
@export var targetable := true
@export var active := true : get = get_active, set = set_active

var damage_rng = RandomNumberGenerator.new()
@onready var hurt_meter = $MeshInstance3D/hurt_meter

#export (NodePath) var spawn_point

@export var recoil_time := 0.0 # animated by recoil_animplayer
var recoil_magnitude := 0.65 #0.65#0.35

@onready var body = $MeshInstance3D
@onready var body_initial_position = body.transform.origin
@onready var body_initial_basis = body.transform.basis

@onready var waist = $waist
@onready var waist_initial_position = waist.transform.origin
@onready var waist_initial_basis = waist.transform.basis

var current_weapon = null

var _level_visits= ","

var _stats = {
	"times_hit_by_bullet": 0,
	"times_fired_weapon": 0,
	"died": 0,
	}


signal has_died(object)

@onready var dui_root = get_node("MeshInstance3D/dui_root")

var inventory_resource = load("res://data/inventory/inventory.gd")
var inventory = inventory_resource.new()

# camera
@onready var player_camera : Camera3D = self.find_child("Camera3D")
var starting_camera_transform : Transform3D


func _ready():
	pprint("initialise begin")
	#spawn_point = get_node(spawn_point)
	damage_rng.randomize()
	health = initial_health
	$icons/death_icon.visible = false
	targetable = visible

	# connect to weapon
	# TODO: replace with player function for switching weapon
	if $MeshInstance3D/weapon_mount.get_child_count() > 0:
		current_weapon = $MeshInstance3D/weapon_mount.get_child(0)
	
	if current_weapon:
		current_weapon.connect("fire",Callable(self,"_on_weapon_fire"))

	# connect to inventory
	inventory.connect("inventory_changed",Callable(dui_root,"_on_inventory_changed"))

	# deck the character with starting weapons in the inventory
	await get_tree().create_timer(1.0).timeout
	var _ps = preload("res://data/weapons/pulse_shard/pulse_shard.tscn")
	
	for _i in range(2):
		var w = _ps.instantiate()
		#w.set_visible(false)
		self.inventory.add_weapon_item( w, 1 )
	
	# and an equipped weapon
	$WeaponController.slot_weapon( _ps.instantiate() )
	pprint("initialise end.")

	# camera
	starting_camera_transform = player_camera.transform


func _process(_delta):
	# recoil checked waist
	var recoil_v = Vector3(0.0, 0.0, recoil_time * -1.0 * recoil_magnitude).rotated(Vector3.UP, waist.get_rotation().y )
	waist.transform.origin = waist_initial_position + recoil_v
	body.transform.origin = body_initial_position + recoil_v

	if self.active:
		# inspect dui
		if Input.is_action_just_pressed("inspect_digetic_ui"):
			dui_root.invoke_inventory_ring()
		
		if Input.is_action_just_released("inspect_digetic_ui"):
			dui_root.devoke_inventory_ring()

		if Input.is_action_just_pressed("inspect_weapons_ui"):
			dui_root.invoke_weapons_ring()
		
		if Input.is_action_just_released("inspect_weapons_ui"):
			dui_root.devoke_weapons_ring()
			
		if Input.is_action_just_pressed("ui_options"):
			dui_root.invoke_options_ring()

#		if Input.is_action_just_released("ui_options"):
#			dui_root.devoke_options_ring()


func set_active(new_value) -> void:
	active = new_value
	$CollisionShape3D.set_disabled( !new_value )  #disabled = !new_value
	targetable = new_value
	
	$Controller.set_physics_process(new_value)
	$Controller.set_process(new_value)
	$Controller.set_process_input(new_value)
	$Controller.set_process_unhandled_input(new_value)
	
	$WeaponController.active = new_value
	if $WeaponController.weapon:
		$WeaponController.weapon.activated = false


func get_active():
	return active


func set_health(new_value) -> void:
	health = new_value
	hurt_meter.set_factor( 1.0 - health/initial_health )
	if health <= 0.0:
		die()


func die() -> void:
	$MeshInstance3D/hurt_meter.visible = false
	$icons/death_icon.visible = true
	set_active(false)
	await get_tree().create_timer(1.5).timeout
	visible = false
	#spawn_point.transport_player_to_spawn_point()
	emit_signal("has_died", self)
	_stats.died += 1


func respawn() -> void:
	set_health(initial_health)
	set_active(true)
	$MeshInstance3D/hurt_meter.visible = true
	$icons/death_icon.visible = false
	visible = true


func _on_weapon_fire(weapon) -> void:
	# recoily
	$recoil_animplayer.stop()#.pause()#.stop()
	$recoil_animplayer.play("recoil_time_animation", -1, 5.0)#3.5)#5.0) #7.5)
	# force
	$Controller.additional_force += -current_weapon.bullet_spawner.global_transform.basis.z.normalized() * weapon.fire_kickback
	_stats.times_fired_weapon += 1


func stop_movement() -> void:
	$Controller.movement = Vector3.ZERO


func bullet_hit(bullet, _collision_info) -> void:
	if !get_active():
		return

	_stats.times_hit_by_bullet += 1
	
	# knockback
	$Controller.additional_force += bullet.global_transform.basis.z.normalized() * bullet.projectile_knockback * 0.5

	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	set_health( health - damage )


func add_level_visit(level_name, door_name) -> void :
	_level_visits += level_name + ":" + door_name + ","	


func add_additional_force(force:Vector3) -> void:
	$Controller.additional_force += force


func pickup( pickup_object ):
	prints(self.get_name(), "picked up", pickup_object.get_name(), "(%s)"%pickup_object.pickup_type)
	
	#orbs
	if pickup_object.pickup_type == "Orb" or pickup_object.pickup_type == "Gem":
		self.inventory.add_orbs( pickup_object.orb_value )
	
	#weapons
	elif pickup_object.pickup_type == "Weapon":
		prints("  inventory add weapon: ","\n     ", pickup_object.weapon.weapon_name)
		
		# weapon becomes parentless, but held in refernce in player's inventory 
		pickup_object.weapon.get_parent().remove_child( pickup_object.weapon )
		self.inventory.add_weapon_item( pickup_object.weapon, 1 )


func set_current_weapon( weapon ) -> void:
	pprint("set_current_weapon() %s"%weapon)
	self.current_weapon = weapon


func pprint(thing) -> void:
	#print("[player] %s"%str(thing))
	print_rich("[code][b][color=Hotpink][player][/color][/b][/code] %s" %str(thing))


func _exit_tree():
	pprint("exiting tree ..")

#func _on_input_event(camera, event, position, normal, shape_idx):
#	pprint("camera %s, event %s, position %s, normal %s, shape_idx %s"%[camera, event, position, normal, shape_idx])
#	$selection_dot.visible = true
#	$selection_dot.transform.origin = position
#
#
#func _on_mouse_entered():
#	#pprint("_on_mouse_entered")
#	pass
#
#
#func _on_mouse_exited():
#	#pprint("_on_mouse_exited")
#	pass
