extends StateMachine

# enemyFSM

func _ready():
	add_state("idle")
	add_state("chase")
	add_state("attack")
	call_deferred("set_state", states.idle)


func _state_logic(delta):
	if state == states.idle:
		parent._idle()


func _get_transition(delta):
	return null


func _enter_state(new_state, old_state):
	pass
	
	
func _exit_state(old_state, new_state):
	pass
