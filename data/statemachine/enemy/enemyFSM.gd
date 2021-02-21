extends StateMachine

# enemyFSM

func _ready():
	add_state("idle")
	add_state("attack")
	add_state("search")
	call_deferred("set_state", "idle")


func _state_logic(delta):
	#if state == states.idle:
	match state:
		"idle":
			parent._idle(delta)
		"attack":
			parent._attack(delta)
		"search":
			parent._search(delta)


func _get_transition(delta):
	return null


func _enter_state(new_state, old_state):
	match new_state:
		"idle":
			parent._idle_enter()
		"attack":
			parent._attack_enter()
		"search":
			parent._search_enter()


func _exit_state(old_state, new_state):
	match new_state:
		"idle":
			pass
		"attack":
			parent._attack_exit()
		"search":
			pass
