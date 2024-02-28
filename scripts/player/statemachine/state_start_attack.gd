extends State


func enter():
	target.start_attack()


func update(_delta):
	movement_direction = get_movement_direction()
	target.move(movement_direction)
