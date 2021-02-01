extends Spatial

export (NodePath) var player


func _ready():
	player = get_node(player)
	transport_player_to_spawn_point()


func _process(delta):
	print("@@@",$arrival_tween.tell())


func transport_player_to_spawn_point():
	player.active = false
	#yield(get_tree().create_timer(1.0), "timeout")
	$arrival_tween.interpolate_property(
		player,
		"translation",
		player.global_transform.origin,
		global_transform.origin,
		$arrival_tween.playback_speed,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	$arrival_tween.start()


func _on_arrival_tween_tween_all_completed():
	player.respawn()
