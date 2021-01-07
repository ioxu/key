extends Node2D

var activated : bool = false setget set_activated, get_activated
var base_magazine_size := 800
var magazine_count : = base_magazine_size
var base_reload_speed := 0.2
var base_fire_rate := 0.08
var firing_time := 0.0
var firing_timer := Timer.new()
var can_fire := false

onready var anim_player = get_node("../AnimationPlayer")
onready var muzzle_flash : MeshInstance = get_node("../geometry_hook/muzzle_flash")
onready var muzzle_flash_light : OmniLight = get_node("../geometry_hook/muzzle_flash_light")
const bullet_scene = preload("res://data/weapons/pulse_shard/pulse_shard_bullet.tscn")
onready var bullet_spawner = get_node("../bullet_spawner")

func _ready():
	print(" - init weapon.pulse_shard")
	add_child(firing_timer)
	firing_timer.wait_time = base_fire_rate
	firing_timer.connect("timeout", self, "_on_timer_timeout")
	muzzle_flash.visible = false
	muzzle_flash_light.visible = false
	anim_player.get_animation("muzzle_flash").set_loop(false)


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
		print(" - pulse_shard activated")
		fire()
		firing_timer.start()
		can_fire = false
	else:
		print(" - pulse_shard DEactivated")
		can_fire = false
		firing_time = 0.0


func fire():
	muzzle_flash.visible = true
	muzzle_flash_light.visible = true
	anim_player.seek(0.0)
	anim_player.play("muzzle_flash")
	print("  pew (%s/%s) %s"%[magazine_count, base_magazine_size, firing_time])
	magazine_count -= 1
	
	var bullet = bullet_scene.instance()
	get_node("/root/").add_child(bullet)
	bullet.set_translation(bullet_spawner.get_global_transform().origin)
	var direction = bullet_spawner.get_global_transform().basis.z
	bullet.look_at( bullet.get_translation() - direction, Vector3.UP)
	bullet.start()

	Input.start_joy_vibration(0, 1.0, 0.0, 0.05)


func get_activated() -> bool:
	return activated


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"muzzle_flash":
			muzzle_flash.visible = false
			muzzle_flash_light.visible = false
