extends StateMachine

# enemyFSM

func _ready():
	add_state("idle")
	add_state("attack")
	call_deferred("set_state", "idle")


func _state_logic(delta):
	#if state == states.idle:
	match state:
		"idle":
			parent._idle(delta)
		"attack":
			parent._attack(delta)


func _get_transition(delta):
	return null


func _enter_state(new_state, old_state):
	print("_enter_state ", new_state, " ", old_state)
	match new_state:
		"idle":
			print("  entering idle")
		"attack":
			print("  entering attack")
	
func _exit_state(old_state, new_state):
	print("_exit_state ", new_state, " ", old_state)	
	match new_state:
		"idle":
			print("  exiting idle")
		"attack":
			print("  exiting attack")
