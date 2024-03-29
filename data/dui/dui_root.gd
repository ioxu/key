extends Node3D

@export var active := true

@export var inventory_ring_npoints := 32
@export var inventory_ring_radius := 2.25

@export_node_path var weapon_mount#@export (NodePath) var weapon_mount 

var _invoke_amount = 0.0

var is_invoked = false
var is_weapons_invoked = false
var is_inventory_invoked = false
var is_options_invoked = false
@onready var options_menu_2d = $viewports/options/options_viewport/options_menu_2d
var _gtime = 0.0

# weapons inv
@onready var weapons_items = $static_stack/inventory_items/weapons_items


func _ready():
	self.visible = false
	Util.set_tree_visible($weapons_ring, false)
	Util.set_tree_visible($inventory_ring, false)
	Util.set_tree_visible($options_ring, false)
	$static_stack/radar_dots.visible = false
	$static_stack/inventory_items.visible = false
	Util.set_tree_visible($static_stack/magazine, false)
	$static_stack.set_as_top_level(true) # to make control not concat parent's transforms 
	
	$inventory_ring.points = Util.ring_points(inventory_ring_npoints, inventory_ring_radius)
	$weapons_ring.points = Util.ring_points(inventory_ring_npoints, inventory_ring_radius * 0.95)
	$options_ring.points = Util.arc_points(32, 45/2.0, 225+ 45/2.0, inventory_ring_radius )
	$options_ring.set_as_top_level(true)

	# connect to weapon
	# TODO: replace with player function for switching weapon
	weapon_mount = get_node(weapon_mount)
	var weapon = null
	if weapon_mount.get_child_count() > 0 :
		weapon = weapon_mount.get_child(0)
	if weapon:
		weapon.connect("magazine_count_changed",Callable(self,"_on_magazine_count_changed"))
	$static_stack/magazine/full_arc.points = Util.arc_points(16, 180, 270, inventory_ring_radius * 0.95 * 0.8)
	$static_stack/magazine/count.points = Util.arc_points(16, 180, 270, inventory_ring_radius * 0.95 * 0.8)

	# filter checked options_menu_2d ViewportTexture?
	#$static_stack/options/screen.get_material_override().get_texture( StandardMaterial3D.TEXTURE_ALBEDO ).flags = Texture2D.FLAGS_DEFAULT + Texture2D.FLAG_ANISOTROPIC_FILTER


func _process(dt):
	_gtime += dt

	if self.active:

		if self.visible:
			# TODO : do this another way
			# realign static_statck
			$static_stack.transform.origin = self.global_transform.origin + Vector3(0.0, 1.25, 0.0)
			$static_stack.set_rotation(Vector3(0.0, 0.0, 0.0))
			$options_ring.transform.origin = self.global_transform.origin + Vector3(0.0, 1.225, 0.0)
			$options_ring.set_rotation(Vector3(0.0, 0.0, 0.0))


			if is_inventory_invoked:
				weapons_items.update( dt, self.global_transform.basis )

		if is_inventory_invoked:
			if Input.is_action_just_pressed("inventory_select"):
				weapons_items.select()
			if Input.is_action_just_released("inventory_select"):
				weapons_items.release_select()
			if Input.is_action_just_pressed("inventory_shift_left"):
				weapons_items.shift_left()
			if Input.is_action_just_pressed("inventory_shift_right"):
				weapons_items.shift_right()


func _input(event):
	if is_options_invoked:
		$viewports/options/options_viewport.push_input(event)
#	if is_inventory_invoked:
#		if Input.is_action_just_pressed("inventory_select"):
#			weapons_items.select()
#		if Input.is_action_just_released("inventory_select"):
#			weapons_items.release_select()
#		if Input.is_action_just_pressed("inventory_shift_left"):
#			weapons_items.shift_left()
#		if Input.is_action_just_pressed("inventory_shift_right"):
#			weapons_items.shift_right()


func _on_magazine_count_changed(_mag_count, norm_mag_count):
	var c = 180 + (270-180) * norm_mag_count
	$static_stack/magazine/count.points = Util.arc_points(16, 180, c, inventory_ring_radius * 0.95 * 0.8)


func invoke_inventory_ring():
	if is_invoked:
		return
	is_invoked = true
	is_inventory_invoked = true
	is_weapons_invoked = false
	is_options_invoked = false
	Util.set_tree_visible($weapons_ring, false)
	Util.set_tree_visible($inventory_ring, true)
	$static_stack/radar_dots.visible = false
	$static_stack/inventory_items.visible = true
	Util.set_tree_visible($static_stack/magazine, false)
	Util.set_tree_visible($options_ring, false)
	Util.set_tree_visible($static_stack/options, false)
	_invoke()


func invoke_weapons_ring():
	if is_invoked:
		return
	is_invoked = true
	is_inventory_invoked = false
	is_weapons_invoked = true
	is_options_invoked = false
	Util.set_tree_visible($weapons_ring, true)
	Util.set_tree_visible($inventory_ring, false)
	$static_stack/radar_dots.visible = true
	$static_stack/inventory_items.visible = false
	Util.set_tree_visible($static_stack/magazine, true)
	Util.set_tree_visible($options_ring, false)
	Util.set_tree_visible($static_stack/options, false)
	_invoke()


func invoke_options_ring():
	if is_options_invoked:
		prints("OPTIONS: DEVOKE")
		devoke_options_ring()
		return
		
	if is_invoked:
		return

	prints("OPTIONS: INVOKE")
	is_invoked = true
	is_inventory_invoked = false
	is_weapons_invoked = false
	is_options_invoked = true
	Util.set_tree_visible($weapons_ring, false)
	Util.set_tree_visible($inventory_ring, false)
	$static_stack/radar_dots.visible = false
	$static_stack/inventory_items.visible = false
	Util.set_tree_visible($static_stack/magazine, false)
	Util.set_tree_visible($options_ring, true)
	Util.set_tree_visible($static_stack/options, true)
	_invoke()
	options_menu_2d.focus()


func _invoke():
	#is_invoked = true
#	$invoke_tween.reset_all()
#	$invoke_tween.remove_all()
#	$invoke_tween.interpolate_property( $static_stack, "scale",
#		Vector3(0.0002, 2.500, 0.0002), Vector3(1.0, 1.0, 1.0), 0.75,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( $inventory_ring, "scale",
#		Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( $weapons_ring, "scale",
#		Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( $options_ring, "scale",
#		Vector3(0.002, 0.002, 0.002), Vector3(1.0, 1.0, 1.0), 0.55,
#		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#	$invoke_tween.interpolate_property( self, "_invoke_amount",
#		0.0, 1.0, 1.0,
#		Tween.TRANS_LINEAR)
#	$invoke_tween.start()
	
	# remove invoke_tween
	$static_stack.scale = Vector3.ONE
	$inventory_ring.scale = Vector3.ONE
	$weapons_ring.scale = Vector3.ONE
	$options_ring.scale = Vector3.ONE
	_invoke_amount = 1.0 

	self.visible = true


func devoke_inventory_ring():
	if $weapons_ring.visible or $options_ring.visible: 
		return
	else:
		_devoke()


func devoke_weapons_ring():
	#if $inventory_ring.visible == true:
	if $inventory_ring.visible or $options_ring.visible:
		return
	else:
		_devoke()


func devoke_options_ring():
	if $inventory_ring.visible or $weapons_ring.visible:
		return
	else:
		_devoke()


func _devoke():
	is_invoked = false
	is_inventory_invoked = false
	is_weapons_invoked = false
	is_options_invoked = false
#	$invoke_tween.reset_all()
#	$invoke_tween.remove_all()
#	$invoke_tween.interpolate_property( $static_stack, "scale",
#		Vector3(1.0, 1.0, 1.0), Vector3(0.0002, 2.50, .0002), 0.4,
#		Tween.TRANS_CUBIC, Tween.EASE_IN)
#	$invoke_tween.interpolate_property( $inventory_ring, "scale",
#		Vector3(1.0, 1.0, 1.0), Vector3(0.002, .002, .002), 0.3,
#		Tween.TRANS_CUBIC, Tween.EASE_IN)
#	$invoke_tween.interpolate_property( $weapons_ring, "scale",
#		Vector3(1.0, 1.0, 1.0), Vector3(0.002, .002, .002), 0.3,
#		Tween.TRANS_CUBIC, Tween.EASE_IN)
#	$invoke_tween.interpolate_property( $options_ring, "scale",
#		Vector3(1.0, 1.0, 1.0), Vector3(0.002, .002, .002), 0.3,
#		Tween.TRANS_CUBIC, Tween.EASE_IN)
#	$invoke_tween.interpolate_property( self, "_invoke_amount",
#		1.0, 0.0, 1.0,
#		Tween.TRANS_LINEAR)
#	$invoke_tween.start()


	# remove invoke_tween
	$static_stack.scale = Vector3(0.002, .002, .002)
	$inventory_ring.scale = Vector3(0.002, .002, .002)
	$weapons_ring.scale = Vector3(0.002, .002, .002)
	$options_ring.scale = Vector3(0.002, .002, .002)
	_invoke_amount = 0.0
	self.visible = false


func _on_invoke_tween_tween_completed(_object, _key):
	if self._invoke_amount == 0.0:
		self.visible = false
		Util.set_tree_visible($weapons_ring, false)
		Util.set_tree_visible($inventory_ring, false)
		$static_stack/radar_dots.visible = false
		$static_stack/inventory_items.visible = false
		Util.set_tree_visible($static_stack/magazine, false)


func get_invoke_amount():
	# TODO : do this another way
	return _invoke_amount


func _on_options_menu_2d_close_options_menu():
	devoke_options_ring()


func _on_inventory_changed( inventory ):
	var checked = $viewports/inventory/inventory_2d_viewport/inventory_2d.find_child("orbs_number")
	checked.text = str(inventory.n_orbs)
	var wn = $viewports/inventory/inventory_2d_viewport/inventory_2d.find_child("weapons_number")
	wn.text = str(inventory.n_weapons)
	
	weapons_items.weapon_inventory_changed( inventory )
	

func pprint(thing) -> void:
	print("[dui_root] %s"%str(thing))
