extends MeshInstance3D
# enemy spawner 

@export var enemy_archetype:PackedScene
@export var rand_spawn_area_size := 5.0

var enemy : CharacterBody3D


func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _input(event):
	if event.is_action_pressed("spawn_enemy"):
		pprint("spawn at %s"%self.get_path())
		enemy = enemy_archetype.instantiate() as CharacterBody3D
		get_tree().get_root().add_child( enemy )
		enemy.global_position = self.global_position + ( Vector3.UP * 2.0 ) + (Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0) ) * rand_spawn_area_size )



func pprint(thing) -> void:
	print("[enemy_spawner] %s"%str(thing))
