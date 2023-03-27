extends "res://data/weapons/weapon.gd"

@export var colour = Color(0.14, 0.68, 0.95)
@export var is_enemy_weapon := false : set = set_is_enemy_weapon

@export var base_magazine_size := 200
@export var casing_eject_force := 3.0
var magazine_count : = 100
var base_reload_speed := 0.2
@export var base_fire_rate := 0.08
@export var fire_kickback := 65.0
var firing_time := 0.0
var firing_timer := Timer.new()
var can_fire := false


signal fired
signal magazine_count_changed(current_magazine_count, normalised_magazine_count)

@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash : MeshInstance3D = $geometry_hook/muzzle_flash
@onready var muzzle_flash_light : OmniLight3D = $geometry_hook/muzzle_flash_light
@onready var muzzle_flash_light_initial_position = muzzle_flash_light.position

@export var eject_casings := true
const bullet_scene = preload("res://data/weapons/pulse_shard/pulse_shard_bullet.tscn")
const bullet_casing_scene = preload("res://data/weapons/pulse_shard/pulse_shard_casing.tscn")
@onready var bullet_spawner = $bullet_spawner


func _ready():
	#pprint("ready() %s"%self.get_path())
	
	#await get_tree().idle_frame
	
#	$bullet_spawner/pulse_shard_bullet.queue_free()
#	$bullet_spawner/pulse_shard_bullet_impact.queue_free()
#	$shell_casing_spawner/pulse_shard_casing.queue_free()

	add_child(firing_timer)
	firing_timer.wait_time = base_fire_rate
	firing_timer.connect("timeout",Callable(self,"_on_timer_timeout"))
	
	
	muzzle_flash.visible = false
	muzzle_flash_light.visible = false
	#anim_player.get_animation("muzzle_flash").set_loop(false)
	anim_player.get_animation("muzzle_flash").set_loop_mode(Animation.LOOP_NONE)

	magazine_count = base_magazine_size

	if self.activated:
		await get_tree().create_timer(0.025).timeout
		set_activated( true )

	pprint("created self: %s"%self)


func set_is_enemy_weapon(new_value):
	is_enemy_weapon = new_value
	if new_value:
		$geometry_hook/muzzle_flash_light.light_color = Color(0.96875, 0.389771, 0.389771)


func _process(dt):
	super(dt)
	if activated:
		firing_time += dt
	if firing_timer.is_stopped():
		can_fire = true


func _on_timer_timeout():
#	pprint("_on_timer_timeout")
	can_fire = true
	if activated:
#		pprint("fire (_on_timer_timeout())")
		fire()
	else:
		firing_timer.stop()


func set_activated(new_value: bool) -> void:
	activated = new_value
	if activated and can_fire:
#		pprint("set_activated, can fire")
#		pprint("fire")
		fire()
		firing_timer.start()
		can_fire = false
		muzzle_flash_light.visible = true
	else:
		can_fire = false
		firing_time = 0.0


func fire():
	$AudioStreamPlayer3D.set_pitch_scale( randf_range(15.0, 35.0) )
	$AudioStreamPlayer3D.play()

	emit_signal("fired", self)
	muzzle_flash.visible = true
	
	muzzle_flash_light.visible = true
	
	var muzz_rand_pos = Vector3(0.2*(randf()-0.5), 0.2*(randf()-0.5), 0.0)
	muzzle_flash_light.set_position( muzzle_flash_light_initial_position + muzz_rand_pos )
	anim_player.stop()#.pause()#.stop(true)
	anim_player.play("muzzle_flash")
	magazine_count -= 1
	if magazine_count == 0:
		magazine_count = base_magazine_size

	emit_signal("magazine_count_changed", magazine_count, float(magazine_count)/base_magazine_size)

	var bullet = bullet_scene.instantiate()
	if is_enemy_weapon:
		bullet.is_enemy_bullet = true
		# -ee
		#pprint("FIRE (e) %s"%bullet)
	get_node("/root/").add_child(bullet)
	bullet.set_position(bullet_spawner.get_global_transform().origin)
	var direction = bullet_spawner.get_global_transform().basis.z
	bullet.look_at( bullet.get_position() - direction, Vector3.UP)
	bullet.start()

	# eject casing
	if eject_casings:
		#await get_tree().create_timer(0.2).timeout
		var casing = bullet_casing_scene.instantiate()
		casing.transform = $shell_casing_spawner.global_transform
		get_node("/root/").add_child(casing)
		var impulse = casing_eject_force * (Vector3(0.0, randf_range(20.0,35.0), 0.0) + casing.transform.basis.x * -randf_range(10.0,20.0)) #25.0
		impulse += global_velocity * 50.0
		casing.apply_impulse(impulse, Vector3.ZERO) # Vector3.ZERO, impulse)
		var t_impulse = ( $shell_casing_spawner.global_transform.basis.y * randf_range( 0.2, 2.0 ) ) + \
			($shell_casing_spawner.global_transform.basis.x * randf_range(-0.5, 0.5 ) )
		
		#casing.apply_torque_impulse( Vector3(-3.0, -3.0, 0.0) * 10000.0 )
		#casing.set_inertia( Vector3.ZERO  )
		casing.apply_torque_impulse( t_impulse )
		#casing.set_inertia( $shell_casing_spawner.global_transform.basis.x * randf_range(-0.5, 0.5 ) * 50.0  )
		
		
		#pprint("constant torque %s"%casing.get_constant_torque() )
		
		#var t_a_v = Vector3(PI*12.0, randf_range( -0.2, 0.2 ), 0.0) * 1.0
		var t_a_v = Vector3(PI * randf_range( -0.15,-0.3 ), 0.0, 0.0) * 25.0
		t_a_v = t_a_v.rotated( Vector3.UP, $shell_casing_spawner.global_transform.basis.get_euler().y )
		casing.set_angular_velocity( t_a_v )
		
		#casing.set_angular_velocity( $shell_casing_spawner.global_transform.basis.x * randf_range(-0.5, 0.5 ) * 300  )
		#casing.set_angular_velocity( $shell_casing_spawner.transform.basis.get_euler() * 5 ) #$shell_casing_spawner.global_transform.basis.get_euler() * 5 )

	if !is_enemy_weapon:
		Input.start_joy_vibration(0, 0.2, 1.0, 0.05)



func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"muzzle_flash":
			muzzle_flash.visible = false
			muzzle_flash_light.visible = false


func randomize_color() -> void:
	prints(self.get_path(), "RANDOMIZE_COLOR")


func pprint(thing) -> void:
	print("[pulse_shard] %s"%str(thing))
