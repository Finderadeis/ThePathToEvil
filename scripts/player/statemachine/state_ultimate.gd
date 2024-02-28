extends State


func enter():
	target.perform_ultimate()
	yield(get_tree().create_timer(0.3), "timeout")
	exit()


func update(_delta):
	target.move(get_movement_direction())


func exit():
	$"../../AnimationPlayer".play("RESET")
	state_machine.transition_to("Walk")
