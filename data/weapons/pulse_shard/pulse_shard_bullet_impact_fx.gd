extends Spatial


func _ready():
	$free_timer.start()


func _on_free_timer_timeout():
	self.queue_free()
