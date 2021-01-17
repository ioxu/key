extends KinematicBody

export var initial_health : float = 1000.0
export var health : float = initial_health
export(float) var movement_speed = 7.5
export(float) var acceleration = 3.0
export(float) var deaceleration = 5.0

var direction := Vector3.ZERO
var initial_movement_speed = movement_speed
var last_direction := Vector3.ZERO
var current_vertical_speed := Vector3.ZERO
var movement := Vector3.ZERO
var max_turn_rate := deg2rad(5.0)
var speed := Vector3.ZERO
var is_airborne : = false
var gravity := -10.0
var jump_acceleration := 3.0
var age := 0.0
var accelerate = acceleration

const DO_TRAVEL_PATH = true
var travel_path = null
const travel_path_script = preload("res://scripts/travel_path_line.gd")

var noise = OpenSimplexNoise.new()
var offset = 0.0

var damage_rng = RandomNumberGenerator.new()

onready var hurt_meter = $MeshInstance/hurt_meter
onready var fsm = $statemachine


func _ready():
	damage_rng.randomize()
	$hurtbox.connect("bullet_hit", self, "bullet_hit")
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 35.0
	offset = damage_rng.randf() * 100

	if DO_TRAVEL_PATH:
		travel_path = ImmediateGeometry.new()
		travel_path.set_script(travel_path_script)
		travel_path.track_object_path = self.get_path()
		travel_path.position_offset = Vector3(0.0, -0.5, 0.0)
		get_node("/root/").add_child(travel_path)


func bullet_hit(bullet):
	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	health -= damage
	hurt_meter.set_factor( 1.0 - health/initial_health )
	print("  bullet damage %s, health %s"%[damage, health])

	if health <= 0.0:
		if DO_TRAVEL_PATH:
			travel_path.queue_free()
		queue_free()


func _idle():
	# wander about a bit
	var rot_y = noise.get_noise_1d( age * 25.0 + offset ) 
	rot_y = sign(rot_y) * bias(abs(rot_y), 0.25) * 0.2
	rotate_y( rot_y )
	direction = global_transform.basis.z 
	var speed_noise = noise.get_noise_1d( age * 15.0 - offset )
	var spd = 0.0
	
	if speed_noise > 0.35:
		spd = bias((speed_noise+1.0)/2.0, 0.2)
	elif speed_noise < -0.35:
		spd = -0.4 * bias((abs(speed_noise)+1.0)/2.0, 0.2)
	movement_speed = spd * 7.5


func _physics_process(delta):
	age += delta

	direction.y = 0.0
	last_direction = direction.normalized()
	var max_speed = movement_speed * direction.normalized()
	accelerate = deaceleration
	if direction.dot(speed) > 0.0:
		accelerate = acceleration
	direction = Vector3.ZERO
	speed = speed.linear_interpolate(max_speed, delta * accelerate)
	movement = transform.basis * speed
	movement = speed

	current_vertical_speed.y += gravity * delta * jump_acceleration
	movement += current_vertical_speed
	move_and_slide(movement, Vector3.UP)
	if is_on_floor():
		current_vertical_speed.y = 0.0
		is_airborne = false

func bias(value, b):
	b = -log2(1.0 - b)
	return 1.0 - pow(1.0 - pow(value, 1.0/b), b)

func log2(value):
	return log(value) / log(2)

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
