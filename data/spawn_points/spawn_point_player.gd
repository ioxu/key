extends Node3D

@export (NodePath) var player


func _ready():
	player = get_node(player)
	transport_player_to_spawn_point()


#func _process(delta):
#	#print("@@@",$arrival_tween.tell())
#	pass


func transport_player_to_spawn_point():
	print("begin recall to spawnpoint ..")
	player.set_active( false )
	#await get_tree().create_timer(1.0).timeout
	$arrival_tween.interpolate_property(
		player,
		"position",
		player.global_transform.origin,
		global_transform.origin,
		$arrival_tween.playback_speed,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)	
	player.visible = false
	$arrival_tween.start()


func _on_arrival_tween_tween_completed(object, key):
	print(".. arrived at spawnpoint")
	#$arrival_tween.stop(player, "position")
	$arrival_tween.remove_all()
	player.respawn()
	
