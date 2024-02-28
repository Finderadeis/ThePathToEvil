extends State


# public / private variables
var direction

func enter():
	$"../../Sprite".animation = "walk"
	$"../../Sprite".playing = true

func update(_delta):
	get_user_input()
	
	direction = get_movement_direction()
	if direction == Vector2(0,0):
		state_machine.transition_to("Idle")
	else:
		target.move(direction)
