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
	#print("_enter_state ", new_state)
	match new_state:
		"idle":
			#print("  entering idle")
			parent._idle_enter()
		"attack":
			#print("  entering attack")
			parent._attack_enter()
	
func _exit_state(old_state, new_state):
	#print("_exit_state ", old_state)
	match new_state:
		"idle":
			#print("  exiting attack")
			pass
		"attack":
			#print("  exiting idle")
			parent._attack_exit()
