extends KinematicBody


export var initial_health : float = 1000.0
export var health : float = initial_health

onready var hurt_meter = $MeshInstance/hurt_meter


var damage_rng = RandomNumberGenerator.new()

func _ready():
	damage_rng.randomize()
	$hurtbox.connect("bullet_hit", self, "bullet_hit")
	
	
func bullet_hit(bullet):
	var damage = damage_rng.randf_range(bullet.damage_range[0], bullet.damage_range[1])
	health -= damage
	hurt_meter.set_factor( 1.0 - health/initial_health )
	print("  bullet damage %s, health %s"%[damage, health])

	if health <= 0.0:
		queue_free()
	


