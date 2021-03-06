extends "res://data/weapons/weapon.gd"

export var is_enemy_weapon := false setget set_is_enemy_weapon

export var base_magazine_size := 800
var magazine_count : = base_magazine_size
var base_reload_speed := 0.2
export var base_fire_rate := 0.08
export var fire_kickback := 65.0
var firing_time := 0.0
var firing_timer := Timer.new()
var can_fire := false

signal fire

onready var anim_player = $AnimationPlayer 
onready var muzzle_flash : MeshInstance = $geometry_hook/muzzle_flash 
onready var muzzle_flash_light : OmniLight = $geometry_hook/muzzle_flash_light
onready var muzzle_flash_light_initial_position = muzzle_flash_light.translation
const bullet_scene = preload("res://data/weapons/pulse_shard/pulse_shard_bullet.tscn")
onready var bullet_spawner = $bullet_spawner 


func _ready():
	#yield(get_tree(), "idle_frame")
	$bullet_spawner/pulse_shard_bullet.queue_free()
	$bullet_spawner/pulse_shard_bullet_impact.queue_free()
	add_child(firing_timer)
	firing_timer.wait_time = base_fire_rate
	firing_timer.connect("timeout", self, "_on_timer_timeout")
	muzzle_flash.visible = false
	muzzle_flash_light.visible = false
	anim_player.get_animation("muzzle_flash").set_loop(false)


func set_is_enemy_weapon(new_value):
	is_enemy_weapon = new_value
	if new_value:
		$geometry_hook/muzzle_flash_light.light_color = Color(0.96875, 0.389771, 0.389771)


func _process(dt):
	if activated:
		firing_time += dt
	if firing_timer.is_stopped():
		can_fire = true


func _on_timer_timeout():
	can_fire = true
	if activated:
		fire()


func set_activated(new_value: bool) -> void:
	activated = new_value
	if activated and can_fire:
		#print(" - pulse_shard activated")
		fire()
		firing_timer.start()
		can_fire = false
	else:
		#print(" - pulse_shard DEactivated")
		can_fire = false
		firing_time = 0.0


func fire():
	emit_signal("fire", self)
	muzzle_flash.visible = true
	muzzle_flash_light.visible = true
	var muzz_rand_pos = Vector3(0.2*(randf()-0.5), 0.2*(randf()-0.5), 0.0)
	muzzle_flash_light.set_translation( muzzle_flash_light_initial_position + muzz_rand_pos )
	anim_player.stop(true)
	anim_player.play("muzzle_flash")
	#print("  pew (%s/%s) %s"%[magazine_count, base_magazine_size, firing_time])
	magazine_count -= 1
	
	var bullet = bullet_scene.instance()
	if is_enemy_weapon:
		bullet.is_enemy_bullet = true

	get_node("/root/").add_child(bullet)
	bullet.set_translation(bullet_spawner.get_global_transform().origin)
	var direction = bullet_spawner.get_global_transform().basis.z
	bullet.look_at( bullet.get_translation() - direction, Vector3.UP)
	bullet.start()

	if !is_enemy_weapon:
		Input.start_joy_vibration(0, 1.0, 0.0, 0.05)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"muzzle_flash":
			muzzle_flash.visible = false
			muzzle_flash_light.visible = false
