extends State


# public / private variables
var timer = 0.0
var direction


func enter():
	timer = target.knockback_time
	target.knockback()
	
	if target.knockback_source.x >= target.get_global_position().x:
		direction = Vector2(-1,0)
	else:
		direction = Vector2(1,0)


func exit():
	timer = 0.0
	state_machine.transition_to("Walk")


func update(delta):
	if timer >= 0:
		timer -= delta
		target.push(direction, "knockback")
	else:
		exit()
